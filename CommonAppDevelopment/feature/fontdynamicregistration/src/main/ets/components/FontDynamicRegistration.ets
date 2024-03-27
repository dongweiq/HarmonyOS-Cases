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
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/common';

// 常量定义

// 字体下载链接
const URL: string = "https://gitee.com/coufran/font-online/raw/master/fonts/SourceHanSerif/SourceHanSerif-ExtraLight.otf";
//字体文件名
const FILE_NAME: string = '/font.TTF';
// 字体下载目录
const CACHE_DIR: string = getContext().cacheDir;
// 下载文件头
const DOWNLOAD_HEADER: string = 'file://';
const DOWNLOAD_BUTTON_TEXT: string = '下载中...';
const TOAST_DURATION: number = 2000;
const DIVIDER_STROKEWIDTH: number = 1;

@Preview
@Component
export struct FontDynamicRegistration {
  @State targetFont: ResourceStr = $r('app.string.font_sans');
  @State targetFont1: string = this.targetFont.toString();
  //控制进度条显隐
  @State progressFlag: boolean = false;
  //进度条进度
  @State downloadTotal: number = 0;
  @State downloadNow: number = 0;
  @State downloadButtonText: ResourceStr = $r('app.string.font_SourceHanSerif');
  @State downloadButtonEnabled: boolean = true;

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
          Stack() {
            if (this.progressFlag) {
              Progress({ value: this.downloadNow, total: this.downloadTotal })
                .color($r('app.color.global_bg'))
                .margin($r('app.integer.progress_margin'))
            }
          }

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
              .backgroundColor($r('app.color.global_bg'))
              .margin({ right: $r('app.integer.button_spacing') })
              .onClick(() => {
                this.targetFont = $r('app.string.font_sans');
              })
            Button(this.downloadButtonText)
              .width($r('app.integer.bt_width'))
              .backgroundColor($r('app.color.global_bg'))
              .enabled(this.downloadButtonEnabled)
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
    logger.info('file exist:' + res);
    if (res) {
      // TODO ：知识点：注册自定义字体
      font.registerFont({
        familyName: $r('app.string.font_SourceHanSerif'),
        familySrc: DOWNLOAD_HEADER + filePath
      })
      // 字体变更为思源宋体
      this.targetFont = $r('app.string.font_SourceHanSerif');
      ;
      logger.info('registerFont successful');
      return;
    }
    this.downloadButtonText = DOWNLOAD_BUTTON_TEXT;
    this.downloadButtonEnabled = false;
    try {
      // TODO ：知识点：下载网络文件
      request.downloadFile(getContext(), {
        url: URL,
        filePath: filePath
      }, (err, downloadTask) => {
        if (err) {
          logger.error('Failed to request the download. Cause: ' + JSON.stringify(err));
          return;
        }
        // 监听下载进度，赋值到状态变量
        downloadTask.on('progress', (receivedSize, totalSize) => {
          this.progressFlag = true;
          this.downloadNow = receivedSize;
          this.downloadTotal = totalSize;
          logger.info("Download receivedSize:" + receivedSize + " totalSize:" + totalSize);
        });

        // 监听下载完成事件
        downloadTask.on('complete', () => {
          this.progressFlag = false;
          this.downloadButtonText = $r('app.string.font_SourceHanSerif');
          ;
          this.downloadButtonEnabled = true;
          try {
            promptAction.showToast({
              message: $r('app.string.toast_message'),
              duration: TOAST_DURATION
            });
          } catch (error) {
            const message = (error as BusinessError).message;
            const code = (error as BusinessError).code;
            logger.error(`showToast args error code is ${code}, message is ${message}`);
          }
          downloadTask.off('progress');
          downloadTask.off('fail');
          font.registerFont({
            familyName: $r('app.string.font_SourceHanSerif'),
            familySrc: DOWNLOAD_HEADER + filePath
          })
          this.targetFont = $r('app.string.font_SourceHanSerif');
          ;
        })

        // 监听下载失败事件
        downloadTask.on('fail', (err: number) => {
          logger.error("DownloadTask failed");
          let res = fs.accessSync(filePath);
          if (res) {
            fs.unlink(filePath);
            downloadTask.off('fail');
          }
        })
      });
    } catch (err) {
      logger.error("Download failed with error message: " + err.message + ", error code: " + err.code);
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


