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

import { logger } from '@ohos/base';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common'; // 导入依赖资源context模块
import request from '@ohos.request'; // 导入上传下载模块

const TAG = 'Multiple_Files_Download';
const BYTE_CONVERSION: number = 1024; // 字节转换
const INIT_PROGRESS: number = 0; // 进度条初始值
let context = getContext(this) as common.UIAbilityContext; // 获取当前页面的上下文

// 从下载链接获取文件名。这里以简单包含文件名的下载链接为例。
function getFileNameFromUrl(url: string): string {
  const segments = url.split('/'); // 将URL字符串按照'/'字符进行分割,返回一个数组。
  return segments.pop() || '未知文件名'; // 使用pop方法从数组的末尾返回最后一个元素。
}

// 单个下载任务
@Component
export struct FileDownloadItem {
  // 文件下载配置
  @State downloadConfig: request.agent.Config = { action: request.agent.Action.DOWNLOAD, url: '' };
  // 下载文件名
  @State fileName: string = '';
  // 下载任务状态
  @State state: string = "";
  // 监听是否全部开始下载
  @Prop @Watch('onDownLoadUpdated') isStartAllDownload: boolean = false;
  // 下载任务对象初始化。用于下载失败和下载过程中暂停和重新启动下载。
  private downloadTask: request.agent.Task | undefined;
  // 待下载任务数量
  @Link downloadCount: number;
  // 下载状态图标显隐控制。下载中显示图标，下载完成或者下载失败隐藏图标
  @State isShow: boolean = false;
  // 是否正在下载标志位
  @State downloading: boolean = false;
  // 下载文件大小。类型字符串
  @State sFileSize: string = "-";
  // 下载文件大小。类型数值
  @State nFileSize: number = 0;
  // 当前已下载数据量。类型字符串
  @State sCurrentDownloadSize: string = "-";
  // 当前已下载数据量。类型数值
  @State nCurrentDownloadSize: number = 0;
  // 下载任务完成回调
  private completedCallback = (progress: request.agent.Progress) => {
    // 下载状态设置为下载完成
    this.state = "下载完成";
    if (this.sFileSize === '未知大小') {
      // 如果下载url文件的服务器采用chunk分块传输文件数据，是获取不到下载文件总大小的。对于这种下载文件大小无法获取到的情况，
      // 本例中下载进度条展示效果是初始未下载时进度为0，总进度为1，当文件下载完成时下载进度值改成1，表示下载完成，同步更新显示到进度条上。
      this.nCurrentDownloadSize = 1;
    }
    // 文件下载完成，待下载任务数量减1
    this.downloadCount--;
    // 隐藏下载状态图标
    this.isShow = false;
  }
  // 下载任务失败回调。任务下载失败一般是由于网络不好，底层重试也失败后进入该下载失败回调。如果网络没问题，建议重新下载再试。
  private failedCallback = (progress: request.agent.Progress) => {
    this.state = "下载失败";
    if (this.downloadTask) {
      // show用于获取下载任务相关信息。
      request.agent.show(this.downloadTask.tid, (err: BusinessError, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          logger.error(TAG, `Failed to show with error message: ${err.message}, error code: ${err.code}`);
          return;
        }
        if (this.downloadTask) {
          // 打印下载失败的任务id和任务状态
          logger.error(TAG, `Failed to download with error downloadTask tid: ${this.downloadTask.tid} state: ${taskInfo.progress.state}`);
          // 隐藏下载状态图标
          this.isShow = false;
        }
      });
    }
  }
  // 暂停任务回调
  private pauseCallback = (progress: request.agent.Progress) => {
    this.state = "已暂停";
    // 切换下载状态图标
    this.downloading = false;
  }
  // 重新启动任务回调。如果下载url文件的服务器不支持分片传输，则文件将重新下载。如果服务器支持分片传输，则会基于之前暂停时的下载进度继续下载。
  private resumeCallback = (progress: request.agent.Progress) => {
    // 切换下载状态图标
    this.downloading = true;
  }
  // 下载进度更新回调
  private progressCallback = (progress: request.agent.Progress) => {
    // 性能知识点: 如果注册了progress下载进度更新监听，不建议在progress下载进度更新回调中加日志打印，减少不必要的性能损耗。
    this.state = "下载中";
    this.downloading = true;
    // 显示下载状态图标
    this.isShow = true;
    if (this.downloadTask) {
      // 第一次开始下载
      if (this.sFileSize === '-') {
        // 如果下载url文件的服务器采用chunk分块传输文件数据，是获取不到下载文件总大小的。传过来的值为-1，则在页面上显示'未知大小'
        if (progress.sizes[0] === -1) {
          this.sFileSize = '未知大小';
          // 文件大小无法获取的情况下，进度条的值设置为0，总进度设置为1
          this.nCurrentDownloadSize = 0;
          this.nFileSize = 1;
        } else {
          // 能获取文件大小时，按实际下载数据量更新进度
          this.nFileSize = progress.sizes[0];
          this.sFileSize = (progress.sizes[0] / BYTE_CONVERSION).toFixed() + 'kb';
          this.nCurrentDownloadSize = progress.processed;
        }
      } else if (this.sFileSize === '未知大小') {
        // 非首次下载(暂停过下载任务后重新启动下载时)，文件大小未知情况时，下载时进度不做更新
        logger.info(TAG, `When the file size is unknown, the download progress will not be updated`);
      } else {
        // 非首次下载(暂停过下载任务后重新启动下载时)，文件大小能获取到的情况，更新下载进度
        this.nCurrentDownloadSize = progress.processed;
      }
      // 用于显示已下载文件数据大小
      this.sCurrentDownloadSize = (progress.processed / BYTE_CONVERSION).toFixed() + 'kb';
    }
  }

  aboutToAppear(): void {
    // 从下载链接获取文件名
    this.fileName = getFileNameFromUrl(this.downloadConfig.url);
  }

  // 监听是否开始下载/暂停下载
  onDownLoadUpdated(): void {
    if (this.isStartAllDownload) {
      // 如果下载失败，则重新下载。下载失败原因一般是网络原因导致。
      if (this.state === "下载失败") {
        // 下载任务完成或者任务失败时，底层会自动销毁任务资源。所以如果需要重新下载，重新创建任务即可。这里只做了初始化task对象
        this.downloadTask = undefined;
      }
      // 下载
      this.startDownload();
    } else {
      // 暂停下载
      this.pauseDownload();
    }
  }

  // 启动下载任务
  startDownload(): void {
    // 首次下载，创建任务
    if (this.downloadTask === undefined) {
      // TODO 知识点：创建下载任务，并注册下载任务相关监听。本例在每个FileDownloadItem中使用request.agent.create创建下载任务。然后在下载任务创建成功后，注册各自下载任务相关监听。本例中注册了下载任务完成回调，下载任务失败回调，下载进度更新回调，暂停任务回调，重新启动任务回调。
      request.agent.create(context, this.downloadConfig).then((task: request.agent.Task) => {
        // 注册下载任务相关回调
        task.on('completed', this.completedCallback); // 下载任务完成回调
        task.on('failed', this.failedCallback); // 下载任务失败回调
        task.on('pause', this.pauseCallback); // 暂停任务回调
        task.on('resume', this.resumeCallback); // 重新启动任务回调
        task.on('progress', this.progressCallback); // 下载进度更新回调

        // TODO 知识点：启动下载任务。本例在每个FileDownloadItem中使用task.start方法启动各自的下载任务。
        task.start((err: BusinessError) => {
          if (err) {
            logger.error(TAG, `Failed to task start with error message: ${err.message}, error code: ${err.code}`);
            return;
          }
          this.downloadTask = task;
        })
      }).catch((err: BusinessError) => {
        logger.error(TAG, `Failed to task create with error message: ${err.message}, error code: ${err.code}`);
      });
    } else {
      // 任务已存在时，继续下载
      this.resumeDownload();
    }
  }

  // 暂停下载任务
  pauseDownload(): void {
    if (this.downloadTask) {
      // TODO 知识点：使用request.agent.show，根据任务id可查询任务的详细信息。本处用于查询下载任务状态
      request.agent.show(this.downloadTask.tid, (err: BusinessError, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          logger.error(TAG, `Failed to show with error message: ${err.message}, error code: ${err.code}`);
          return;
        }
        // 判断当前下载任务状态是否满足暂停条件。
        if (this.downloadTask && (taskInfo.progress.state === request.agent.State.WAITING || taskInfo.progress.state
          === request.agent.State.RUNNING || taskInfo.progress.state === request.agent.State.RETRYING)) {
          // TODO 知识点：使用task.pause可以暂停正在等待WAITING/正在运行RUNNING/正在重试RETRYING的后台下载任务。
          this.downloadTask.pause().then(() => {
            // 暂停任务成功
          }).catch((err: BusinessError) => {
            logger.error(TAG, `Failed to pause with error message: ${err.message}, error code: ${err.code}`);
          });
        }
        else {
          if (this.downloadTask) {
            // 不满足暂停任务条件
            logger.info(TAG, `Not meeting the pause task conditions,current task state: ${taskInfo.progress.state}`);
          }
        }
      });
    }
  }

  // 重新启动下载任务
  resumeDownload(): void {
    if (this.downloadTask) {
      // 查询任务状态
      request.agent.show(this.downloadTask.tid, (err: BusinessError, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          logger.error(TAG, `Failed to show with error message: ${err.message}, error code: ${err.code}`);
          return;
        }
        // 判断如果任务是暂停状态，则重新启动下载任务
        if (this.downloadTask && taskInfo.progress.state === request.agent.State.PAUSED) {
          // TODO 知识点：使用task.resume可以重新启动任务，可恢复暂停的后台任务。
          this.downloadTask.resume((err: BusinessError) => {
            if (err) {
              logger.error(TAG, `Failed to resume with error message: ${err.message}, error code: ${err.code}`);
              return;
            }
            // 重新启动下载任务成功
          });
        }
      });
    }
  }

  build() {
    RelativeContainer() {
      Image($r('app.media.file'))
        .height($r('app.integer.image_size_50'))
        .width($r('app.integer.image_size_50'))
        .id('fileImage')

      Text(this.fileName)
        .fontSize($r('app.integer.text_font_size_14'))
        .padding({ left: $r('app.integer.padding_20') })
        .alignRules({
          left: { anchor: 'fileImage', align: HorizontalAlign.End }
        })
        .id('fileName')

      Image(this.downloading ? $r('app.media.start') : $r('app.media.stop'))
        .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
        .height($r('app.integer.image_size_25'))
        .width($r('app.integer.image_size_25'))
        .margin({ top: $r('app.integer.margin_top_7') })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .id("downloadImage")
        .onClick(() => {
          // 这里未做实际功能，仅做展示
          AlertDialog.show({
            message: $r('app.string.function_only_display_purposes'),
            alignment: DialogAlignment.Center
          });
        })

      Text(this.sCurrentDownloadSize + "/" + this.sFileSize)
        .fontSize($r('app.integer.text_font_size_12'))
        .width($r('app.string.text_width_40'))
        .fontColor($r('app.color.donwnolad_text_font_color'))
        .margin({ top: $r('app.integer.margin_top_7') })
        .padding({ left: $r('app.integer.padding_20') })
        .alignRules({
          top: { anchor: 'downloadImage', align: VerticalAlign.Center },
          left: { anchor: 'fileImage', align: HorizontalAlign.End }
        })
        .id('downloadVal')

      Text(this.state)
        .fontSize($r('app.integer.text_font_size_12'))
        .fontColor($r('app.color.donwnolad_text_font_color'))
        .margin({ top: $r('app.integer.margin_top_7') })
        .alignRules({
          top: { anchor: 'downloadImage', align: VerticalAlign.Center },
          left: { anchor: 'downloadVal', align: HorizontalAlign.End },
          right: { anchor: 'downloadImage', align: HorizontalAlign.Start }
        })
        .id("state")
      // 下载进度条，用于显示从下载进度更新回调中获取到的已下载数据大小
      Progress({ value: INIT_PROGRESS, total: this.nFileSize, type: ProgressType.Capsule })
        .alignRules({
          top: { anchor: "fileImage", align: VerticalAlign.Bottom }
        })
        .value(this.nCurrentDownloadSize)
        .height($r('app.integer.progress_height'))
        .margin({ top: $r('app.integer.margin_top_5') })
        .id("progress")
    }
    .width($r('app.string.relative_container_width'))
    .height($r('app.string.relative_container_height'))
  }
}