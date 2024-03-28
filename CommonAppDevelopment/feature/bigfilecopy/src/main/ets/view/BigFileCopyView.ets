/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 1. 根据rawfile获得其所在hap包的RawFileDescriptor
 * 2. 根据RawFileDescriptor中的fd、偏移、文件长度，使用buffer进行内容读取
 * 3. 调用图库的预览器对复制的文件进行预览，以验证复制过程的正确性
 */

import { BigFileCopyConstants } from '../constants/BigFileCopyConstants';
import { common, wantConstant } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { fileUri } from '@kit.CoreFileKit';
import { resourceManager } from '@kit.LocalizationKit';
import Want from '@ohos.app.ability.Want';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';
import fs from '@ohos.file.fs';


@Extend(Button)
function customButtonStyle() {
  .width(BigFileCopyConstants.COMPONENT_SIZE)
  .fontSize($r("sys.float.ohos_id_text_size_body1"))
  .margin({ top: $r("sys.float.ohos_id_elements_margin_vertical_m") })
}

@Component
export struct BigFileCopyView {
  @State progress: number = BigFileCopyConstants.PROGRESS_MIN;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  fileName: string = BigFileCopyConstants.TEST_FILE_NAME;
  targetFilePath: string = "";
  @State isCopyFinished: boolean = false;
  @State isEnableSmooth: boolean = true;
  @State isPreview: boolean = false;

  // TODO：知识点：测试文件用的是图片格式，在复制完之后调用图库打开以查看效果
  previewImage(): void {
    if (this.targetFilePath.length === 0 || !this.isCopyFinished) {
      promptAction.showToast({ message: $r("app.string.prompt_msg") });
      return;
    }
    const want: Want = {
      flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
      action: BigFileCopyConstants.ACTION,
      uri: fileUri.getUriFromPath(this.targetFilePath),
      type: BigFileCopyConstants.MIMETYPE
    };
    this.context.startAbility(want).then(() => {
      console.info("open file success");
    })
  }

  // TODO 文件复制较为耗时，可放在子线程进行
  copyFile2Sandbox() {
    this.isCopyFinished = false;
    // TODO：知识点：这里获取到的fd并不是目标文件的fd，而是文件所属hap包的fd
    const data: resourceManager.RawFileDescriptor = this.context.resourceManager.getRawFdSync(this.fileName);
    const targetPath: string = this.context.filesDir + "/" + this.fileName;
    const destFile: fs.File = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    let buffSize: number = BigFileCopyConstants.BUFF_SIZE;
    const buffer: ArrayBuffer = new ArrayBuffer(Math.min(buffSize, data.length));
    let off: number = 0; // 记录读取位置的偏移（相较于文件起始偏移）
    let len: number = 0; // 本次读取内容的实际长度
    let readedLen: number = 0; // 记录已读文件长度
    // TODO：知识点：因为获取的是所属hap包的fd，这里需要通过目标文件的大小和偏移进行复制
    while (len = fs.readSync(data.fd, buffer, { offset: data.offset + off, length: buffSize })) {
      readedLen += len;
      fs.writeSync(destFile.fd, buffer, { offset: off, length: len });
      this.progress = Math.floor((readedLen / data.length) * 100); // 小数转换成百分比
      off = off + len;
      if ((data.length - readedLen) < buffSize) {
        buffSize = data.length - readedLen;
      }
    }
    this.targetFilePath = targetPath;
    fs.close(destFile.fd);
    this.isCopyFinished = true;
  }

  setIsPreview(status: boolean): void {
    animateTo({ duration: BigFileCopyConstants.ANIMATION_DURATION, curve: Curve.Friction }, () => {
      this.isPreview = status;
    })
  }

  build() {
    Column() {
      Stack() {
        if (!this.isPreview) {
          Progress({
            value: this.progress,
            total: BigFileCopyConstants.PROGRESS_MAX,
            type: ProgressType.Eclipse
          })
            .size({ width: BigFileCopyConstants.COMPONENT_SIZE, height: BigFileCopyConstants.COMPONENT_SIZE })
            .style({ strokeWidth: $r("app.integer.progress_stroke_width"), enableSmoothEffect: this.isEnableSmooth })
        } else {
          // TODO：知识点：Image组件加载沙箱路径需要加前缀 file://
          Image(BigFileCopyConstants.SANDBOX_PREFIX + this.targetFilePath)
            .width(BigFileCopyConstants.COMPONENT_SIZE)
            .height(BigFileCopyConstants.COMPONENT_SIZE)
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_m"))
        }
      }

      Text(`当前复制进度：${this.progress}%`)
        .margin({ top: $r("sys.float.ohos_id_elements_margin_vertical_m") })
      Button($r("app.string.copy_button_msg"))
        .customButtonStyle()
        .enabled(!this.isCopyFinished)
        .onClick(() => {
          this.copyFile2Sandbox();
        })
      Button($r("app.string.reset_button_msg"))
        .customButtonStyle()
        .enabled(this.isCopyFinished)
        .onClick(() => {
          this.progress = BigFileCopyConstants.PROGRESS_MIN;
          this.isCopyFinished = false;
          this.setIsPreview(false);
        })
      Button($r("app.string.preview_button_msg"))
        .customButtonStyle()
        .enabled(this.isCopyFinished)
        .onClick(() => {
          this.setIsPreview(true);
        })
    }
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
    .justifyContent(FlexAlign.Center)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getBigFileCopyView(): void {
  BigFileCopyView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.BIG_FILE_COPY, wrapBuilder(getBigFileCopyView));