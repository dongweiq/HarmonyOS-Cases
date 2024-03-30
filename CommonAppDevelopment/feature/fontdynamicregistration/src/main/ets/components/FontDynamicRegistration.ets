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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { request } from '@kit.BasicServicesKit';
import { font } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { logger } from '@ohos/common';

// 常量定义

const TAG: string = 'FontDynamicRegistration'

// 字体下载链接
const URL: string = "https://gitee.com/coufran/font-online/raw/master/fonts/SourceHanSerif/SourceHanSerif-ExtraLight.otf";
//字体文件名
const FILE_NAME: string = '/font.TTF';
// 字体下载目录
const CACHE_DIR: string = getContext().cacheDir;
// 下载文件头
const DOWNLOAD_HEADER: string = 'file://';
const PROGRESS_CONTENT: string = '思源宋体';
const PROGRESS_CONTENT_START_DOWNLOADING: string = '准备中...';
const DIVIDER_STROKEWIDTH: number = 1;

@Preview
@Component
export struct FontDynamicRegistration {
  @State targetFont: ResourceStr = $r('app.string.font_sans');
  //进度条进度
  @State downloadTotal: number = 0;
  @State downloadNow: number = 0;
  @State progressContent: string | undefined = PROGRESS_CONTENT;
  @State progressColor: ResourceColor = $r('app.color.progress_normal');
  @State progressFontColor: ResourceColor = $r('app.color.progress_font_normal');
  @State progressBgColor: ResourceColor = $r('app.color.progress_bg_normal');

  build() {
    Column() {
      Column() {
        Column() {
          Text($r('app.string.main_title'))
            .fontSize($r('app.integer.title_font_size'))
            .textAlign(TextAlign.Start)
          Text($r('app.string.question'))
            .fontFamily(this.targetFont)
            .fontSize($r('app.integer.body_font_size'))
            .margin({ top: $r('app.integer.body_text_margin') })
            .padding($r('app.integer.body_text_padding'))
            .width($r('app.string.text_dialog_width'))
            .borderRadius($r('app.integer.body_text_borderRadius'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.global_bg'))
            .alignSelf(ItemAlign.End)

          Text($r('app.string.answer'))
            .fontFamily(this.targetFont)
            .fontSize($r('app.integer.body_font_size'))
            .margin({ top: $r('app.integer.body_text_margin') })
            .padding($r('app.integer.body_text_padding'))
            .width($r('app.string.text_dialog_width'))
            .borderRadius($r('app.integer.body_text_borderRadius'))
            .backgroundColor($r('app.color.gery_bg'))

        }.width($r('app.string.text_wrapper_width'))
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text() {
            Span($r('app.string.target_font'))
            Span(this.targetFont)
          }

          Divider()
            .margin($r('app.integer.divider_margin'))
            .strokeWidth(DIVIDER_STROKEWIDTH)
          Row() {
            Button($r('app.string.font_sans'))
              .width($r('app.integer.bt_width'))
              .height($r('app.integer.bt_height'))
              .backgroundColor($r('app.color.global_bg'))
              .margin({ right: $r('app.integer.button_spacing') })
              .onClick(() => {
                this.targetFont = $r('app.string.font_sans');
              })
            Progress({ value: this.downloadNow, total: this.downloadTotal, type: ProgressType.Capsule })
              .width($r('app.integer.bt_width'))
              .height($r('app.integer.bt_height'))
              .style({
                borderColor: $r('app.color.progress_bg_normal'),
                content: this.progressContent,
                showDefaultPercentage: true,
                fontColor: this.progressFontColor
              })
              .color(this.progressColor)
              .backgroundColor(this.progressBgColor)
              .onClick(() => {
                this.downloadAndRegister();
              })
          }
        }
        .width($r('app.string.bottom_wrapper_width'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .height($r('app.string.second_wrapper_size'))
      .width($r('app.string.second_wrapper_size'))
    }.width($r('app.string.top_wrapper_size'))
    .height($r('app.string.top_wrapper_size'))
    .justifyContent(FlexAlign.Center)
  }

  downloadAndRegister() {
    // 检查文件是否存在
    const filePath = CACHE_DIR + FILE_NAME;
    let res = fs.accessSync(filePath);
    logger.info(TAG, `file exist:${res}`);
    if (res) {
      // TODO ：知识点：注册自定义字体
      font.registerFont({
        familyName: $r('app.string.font_SourceHanSerif'),
        familySrc: DOWNLOAD_HEADER + filePath
      })
      // 字体变更为思源宋体
      this.targetFont = $r('app.string.font_SourceHanSerif');
      logger.info(TAG, 'registerFont successful');
      return;
    }
    try {
      this.progressContent = PROGRESS_CONTENT_START_DOWNLOADING;
      this.progressColor = $r('app.color.progress_downloading');
      this.progressFontColor = $r('app.color.progress_font_downloading');
      this.progressBgColor = $r('app.color.progress_bg_downloading');
      // TODO ：知识点：下载网络文件
      request.downloadFile(getContext(), {
        url: URL,
        filePath: filePath
      }, (err, downloadTask) => {
        if (err) {
          logger.error(TAG, `Failed to request the download. Cause: ${JSON.stringify(err)}`);
          return;
        }
        // 监听下载进度，赋值到状态变量
        downloadTask.on('progress', (receivedSize, totalSize) => {
          this.progressContent = undefined;
          this.downloadNow = receivedSize;
          this.downloadTotal = totalSize;
          logger.info(TAG, `Download receivedSize:${receivedSize},totalSize: ${totalSize}`);
        });

        // 监听下载完成事件
        downloadTask.on('complete', () => {
          this.progressColor = $r('app.color.progress_normal');
          this.progressFontColor = $r('app.color.progress_font_normal');
          this.progressBgColor = $r('app.color.progress_bg_normal');
          this.progressContent = PROGRESS_CONTENT;
          downloadTask.off('progress');
          downloadTask.off('fail');
          font.registerFont({
            familyName: $r('app.string.font_SourceHanSerif'),
            familySrc: DOWNLOAD_HEADER + filePath
          })
          this.targetFont = $r('app.string.font_SourceHanSerif');
        })

        // 监听下载失败事件
        downloadTask.on('fail', (err: number) => {
          logger.error(TAG, "DownloadTask failed");
          let res = fs.accessSync(filePath);
          if (res) {
            fs.unlink(filePath);
            downloadTask.off('fail');
          }
        })
      });
    } catch (err) {
      logger.error(TAG, `Download failed with error message:  + ${err.message} + , error code:  + ${err.code}`);
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getFontDynamicRegistration(): void {
  FontDynamicRegistration();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.FONT_DYNAMIC_REGISTRATION, wrapBuilder(getFontDynamicRegistration));


