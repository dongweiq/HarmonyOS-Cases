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

import http from '@ohos.net.http';
import ResponseCode from '@ohos.net.http';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base'
import common from '@ohos.app.ability.common';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import type { Permissions } from '@ohos.abilityAccessCtrl';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.READ_MEDIA',
  'ohos.permission.WRITE_MEDIA'
];

/**
 * 实现步骤：
 * 点击上部“下载”按钮进入”下载网络图片到手机相册”场景示例；点击下部“下载到指定路径”按钮进入”下载文件到指定用户目录”场景示例，
 * 从而实现手机相册并进行网络图片的下载和保存。
 * photoAccessHelper参考文档：
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-photoaccesshelper
 * saveButton参考文档
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/savebutton-0000001820999677
 */

@Component
export struct SaveNetWorkPictures {
  @State image: PixelMap | undefined = undefined;
  @State photoAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined; // 相册模块管理实例
  @State imageBuffer: ArrayBuffer | undefined = undefined; // 图片ArrayBuffer

  /**
   * 通过http的request方法从网络下载图片资源
   */
  async getPicture() {
    http.createHttp()
      .request('https://gitee.com/harmonyos-cases/cases/raw/master/CommonAppDevelopment/feature/variablewatch/src/main/resources/base/media/grape.png',
        (error: BusinessError, data: http.HttpResponse) => {
          if (error) {
            // 下载失败时弹窗提示检查网络，不执行后续逻辑
            promptAction.showToast({
              message: $r('app.string.image_request_fail'),
              duration: 2000
            })
            return
          }
          this.transcodePixelMap(data);
          // 判断网络获取到的资源是否为ArrayBuffer类型
          if (data.result instanceof ArrayBuffer) {
            this.imageBuffer = data.result as ArrayBuffer;
          }
        }
      )
  }

  /**
   * 使用createPixelMap将ArrayBuffer类型的图片装换为PixelMap类型
   * @param data：网络获取到的资源
   */
  transcodePixelMap(data: http.HttpResponse) {
    if (ResponseCode.ResponseCode.OK === data.responseCode) {
      let imageData: ArrayBuffer = data.result as ArrayBuffer;
      // 通过ArrayBuffer创建图片源实例。
      let imageSource: image.ImageSource = image.createImageSource(imageData);
      let options: image.InitializationOptions = {
        'alphaType': 0, // 透明度
        'editable': false, // 是否可编辑
        'pixelFormat': 3, // 像素格式
        'scaleMode': 1, // 缩略值
        'size': { height: 100, width: 100 }
      }; // 创建图片大小

      // 通过属性创建PixelMap
      imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
        this.image = pixelMap;
      });
    }
  }

  /**
   * 保存ArrayBuffer到图库
   * @param buffer：图片ArrayBuffer
   * @returns
   */
  async saveImage(buffer: ArrayBuffer | string): Promise<void> {
    let context = getContext(this) as common.UIAbilityContext; // 获取getPhotoAccessHelper需要的context
    let helper = photoAccessHelper.getPhotoAccessHelper(context); // 获取相册管理模块的实例
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg'); // 指定待创建的文件类型、后缀和创建选项，创建图片或视频资源
    let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    await fs.write(file.fd, buffer);
    await fs.close(file.fd);
  }

  /**
   * 保存ArrayBuffer到用户选择的路径
   * @param buffer：图片ArrayBuffer
   * @returns
   */
  async pickerSave(buffer: ArrayBuffer | string): Promise<void> {
    const photoSaveOptions = new picker.PhotoSaveOptions(); // 创建文件管理器保存选项实例
    photoSaveOptions.newFileNames = ['PhotoViewPicker ' + new Date().getTime() + '.jpg'] // 保存文件名（可选）
    const photoViewPicker = new picker.PhotoViewPicker;
    photoViewPicker.save(photoSaveOptions)
      .then(async (photoSvaeResult) => {
        console.info('PhotoViewPicker.save successfully,photoSvaeResult uri:' + JSON.stringify(photoSvaeResult));
        let uri = photoSvaeResult[0];
        let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        await fs.write(file.fd, buffer);
        await fs.close(file.fd);
        promptAction.showToast({
          message: $r('app.string.save_picture'),
          duration: 2000
        })
      })
  }

  async aboutToAppear(): Promise<void> {
    let context = getContext(this) as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    await atManager.requestPermissionsFromUser(context, PERMISSIONS);
    this.getPicture();
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.title'))
          .fontSize($r('app.string.ohos_id_text_size_headline'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.string.ohos_id_elements_margin_vertical_m') })
        Text($r('app.string.content'))
      }
      .backgroundColor($r('app.color.ohos_id_color_sub_background'))
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      .padding($r('app.string.ohos_id_card_padding_start'))

      Image(this.image)
        .objectFit(ImageFit.Contain)
        .width('50%')
        .height($r('app.integer.image_height'))

      SaveButton()
        .width($r('app.string.savebutton_width'))
        .onClick(async () => {
          if (this.imageBuffer !== undefined) {
            await this.saveImage(this.imageBuffer);
            promptAction.showToast({
              message: $r('app.string.image_request_success'),
              duration: 2000
            })
          }
        })

      Button($r("app.string.picker_save"))
        .margin({ top: $r('app.string.ohos_id_elements_margin_vertical_m') })
        .height($r('app.string.button_height'))
        .onClick(async () => {
          if (this.imageBuffer !== undefined) {
            this.pickerSave(this.imageBuffer);
          }
        })
    }
    .height('100%')
    .margin($r('app.string.ohos_id_card_margin_start'))
  }
}

;
