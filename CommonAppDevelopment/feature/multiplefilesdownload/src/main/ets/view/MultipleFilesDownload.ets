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

import { FileDownloadItem } from './FileDownloadItem';
import request from '@ohos.request'; // 导入上传下载模块。需要配置ohos.permission.INTERNET权限
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton'; // 分段按钮,仅用于ux展示

/**
 * 实现步骤
 * 1.配置下载参数。一个下载任务需要配置对应一套下载参数request.agent.Config。本例中使用downloadConfig方法简单配置了下载文件的url，实际业务
 * 中请按实际情况按需配置。
 * 2.创建多个文件下载监听实例。单个文件下载监听只需要配置下载参数，创建下载任务，注册下载任务相关监听，启动下载任务即可实现。而要实现多文件下载监听，
 * 需要每个下载任务注册独立的下载监听回调。本例通过封装自定义组件FileDownloadItem，在每个FileDownloadItem中创建各自的下载任务和监听回调，从
 * 而实现多文件下载监听。
 * 3.创建下载任务，并注册下载任务相关监听。本例在每个FileDownloadItem中使用request.agent.create创建下载任务。然后在下载任务创建成功后，注
 * 册各自下载任务相关监听。本例中注册了下载任务完成回调，下载任务失败回调，下载进度更新回调，暂停任务回调，重新启动任务回调。
 * 4.启动下载任务。本例在每个FileDownloadItem中使用task.start方法启动各自的下载任务。
 * 5.本例中下载任务用到的其他操作：使用request.agent.show，根据任务id可查询任务的详细信息。使用task.pause可以暂停正在等待WAITING/正在运行
 * RUNNING/正在重试RETRYING的后台下载任务。使用task.resume可以重新启动任务，可恢复暂停的后台任务。
 */

const NO_TASK: number = 0; // 0个下载任务

// 配置下载参数，这里以简单配置url为例
function downloadConfig(downloadUrl: string): request.agent.Config {
  // TODO 知识点：配置下载参数。一个下载任务需要配置对应一套下载参数request.agent.Config。本例中使用downloadConfig方法简单配置了下载文件的url，实际业务中请按实际情况按需配置。
  let config: request.agent.Config = {
    action: request.agent.Action.DOWNLOAD, // 配置任务选项，这里配置为下载任务
    url: downloadUrl, // 配置下载任务url
    overwrite: true, // 下载过程中路径已存在时的解决方案选择。true表示覆盖已存在的文件
    method: 'GET', // HTTP标准方法。下载时，使用GET或POST。
    saveas: './', // 这里'./'表示下载至应用当前缓存路径下。
    mode: request.agent.Mode.BACKGROUND, // 任务模式设置后台任务。
    gauge: true // 后台任务的过程进度通知策略，仅应用于后台任务。true表示发出每个进度已完成或失败的通知。
  };
  return config;
}

@Component
export struct MultipleFilesDownload {
  // 文件下载链接数组
  private downloadUrlArray: string[] = ['https://gitee.com/openharmony/applications_app_samples/raw/master/code/Solutions/Shopping/OrangeShopping/feature/navigationHome/src/main/resources/base/media/favor_list_tea.png', 'https://gitee.com/openharmony/applications_app_samples/raw/master/code/Solutions/Shopping/OrangeShopping/feature/navigationHome/src/main/resources/base/media/favor_list_tree.png'];
  // 文件下载配置数组
  @State downloadConfigArray: request.agent.Config[] = [];
  // 是否全部开始下载
  @State isStartAllDownload: boolean = false;
  // 待下载任务数量
  @State downloadCount: number = 0;
  // 分段按钮，仅用于ux展示
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.file_upload') }, { text: $r('app.string.download_list') }, {
      text: $r('app.string.album_backup')
    }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    selectedFontColor: Color.White,
    selectedBackgroundColor: $r('app.color.selected_background_color'),
    backgroundColor: $r('app.color.background_color')
  })
  @State tabSelectedIndexes: number[] = [1];

  // 下载信息初始化
  aboutToAppear(): void {
    for (let i = 0; i < this.downloadUrlArray.length; i++) {
      let config: request.agent.Config = downloadConfig(this.downloadUrlArray[i]);
      // 下载配置存入数组
      this.downloadConfigArray.push(config)
    }
    // 下载数量，用于显示页面上下载队列数量
    this.downloadCount = this.downloadUrlArray.length;
  }

  build() {
    Column() {
      Text($r('app.string.transfer_list'))
        .fontSize($r('app.integer.text_font_size_25'))
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
      SegmentButton({ options: this.tabOptions, selectedIndexes: $tabSelectedIndexes })
        .margin({ top: $r('app.integer.margin_top_20'), bottom: $r('app.integer.margin_bottom_12') })
      Row() {
        Row() {
          Text($r('app.string.download_queue')).fontSize($r('app.integer.text_font_size_20'))
          Text(this.downloadCount.toString()).fontSize($r('app.integer.text_font_size_20'))
        }.width($r('app.string.row_width_50'))

        Row() {
          // this.downloadCount > 0用于当存在未完成的下载任务时才可以暂停下载
          Text(this.isStartAllDownload && this.downloadCount > NO_TASK ? "全部暂停" : "全部开始")
            .fontSize($r('app.integer.text_font_size_20'))
            .fontColor($r('app.color.download_text_color'))
            .textAlign(TextAlign.End)
            .width($r('app.string.text_width_100'))
            .onClick(() => {
              if (this.downloadCount === NO_TASK) {
                AlertDialog.show({ message: $r('app.string.download_completed'), alignment: DialogAlignment.Center });
                return;
              }
              this.isStartAllDownload = !this.isStartAllDownload;
            })
        }.width($r('app.string.row_width_50'))
      }.width($r('app.string.row_width_100'))

      Row() {
        List() {
          /**
           * 本例只展示下载列表。由于每个应用request.agent.create最多支持创建10个未完成的任务，数量较小，所以这里使用ForEach展示下载列表。
           * 如果需要显示大量历史下载完成任务信息，建议使用LazyForEach提升性能。create相关限制说明请参考https://developer.huawei.com/
           * consumer/cn/doc/harmonyos-references/js-apis-request-0000001774281338#ZH-CN_TOPIC_0000001774281338__request
           * agentcreate10。
           */
          ForEach(this.downloadConfigArray, (item: request.agent.Config) => {
            ListItem() {
              // TODO 知识点：创建多个文件下载监听实例。单个文件下载监听只需要配置下载参数，创建下载任务，注册下载任务相关监听，启动下载任务即可实现。而要实现多文件下载监听，需要每个下载任务注册独立的下载监听回调。本例通过封装自定义组件FileDownloadItem，在每个FileDownloadItem中创建各自的下载任务和监听回调，从而实现多文件下载监听。
              FileDownloadItem({
                downloadConfig: item, // 文件下载配置
                isStartAllDownload: this.isStartAllDownload, // 是否全部开始下载
                downloadCount: this.downloadCount // 待下载任务数量
              })
            }.margin({ bottom: $r('app.integer.margin_bottom_18') })
          }, (item: request.agent.Config) => JSON.stringify(item))
        }
      }
      .height($r('app.string.row_height'))
    }.padding($r('app.integer.padding_15'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getMultipleFilesDownload(): void {
  MultipleFilesDownload();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.MULTIPLE_FILES_DOWNLOAD, wrapBuilder(getMultipleFilesDownload));