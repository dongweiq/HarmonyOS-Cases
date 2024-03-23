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

import { FileListDataSource } from '../model/FileListDataSource';
import { FileItem } from '../model/FileItemModel';
import worker, { MessageEvents } from '@ohos.worker'; // 引入worker模块
import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs'; // 引入文件管理模块
import { logger } from '@ohos/base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';
import { promptAction } from '@kit.ArkUI';

const TAG = 'DecompressFileMainPage';
const LAYOUT_WEIGHT = 1;
const CACHED_COUNT = 5; // LazyForEach预加载的Item数量
const LINEAR_GRADIENT_START = 0; // 颜色渐变起始位置
const LINEAR_GRADIENT_END = 1; // 颜色渐变结束位置

/**
 * 实现步骤：
 * 1. 将项目目录rawfile下的压缩文件写入到应用的沙箱目录，用于后续介绍解压操作。
 * 2. 解压按钮回调中创建Worker线程，主线程使用postMessage()向Worker线程发送应用沙箱路径和压缩文件名称，使用Worker子线程解压文件。
 * 3. 主线程接收Worker子线程发送过来的解压文件所在沙箱目录。
 * 4. 根据解压后的文件所属沙箱目录，获取解压后的文件列表。
 */

@Component
export struct DecompressFileView {
  @State pathDir: string = ''; // 应用沙箱目录
  @State outFileDir: string = ''; // 解压后的文件所处的应用沙箱目录
  private rawfilePath: string = ''; // rawfile压缩文件的应用沙箱路径
  private rawfileZipName: string = 'test.zip'; // 待解压的文件名
  private context: Context = getContext(this);
  private fileListData: FileListDataSource = new FileListDataSource(); // 解压后的文件列表

  aboutToAppear() {
    this.initZip(this.rawfileZipName)
  }

  // 性能：使用Worker子线程解压文件，https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/multi_thread_capability.md/
  decompressFileByWorker(rawfileZipName: string): void {
    /**
     * TODO：知识点：主线程中使用new worker.ThreadWorker创建Worker对象。
     * TODO：知识点：@标识路径加载形式：所有种类的模块加载本地HAR中的Worker线程文件，加载路径规则：@{moduleName}/ets/{relativePath}。
     */
    let workerInstance: worker.ThreadWorker = new worker.ThreadWorker('@decompressfile/ets/workers/Worker.ets');
    // TODO：知识点：主线程在onmessage中接收来自worker线程的消息。
    workerInstance.onmessage = (e: MessageEvents): void => {
      if (e.data) {
        promptAction.showToast({
          message: $r('app.string.decompress_file_toast')
        });
        this.outFileDir = e.data;
        logger.info(TAG, `Decompressed Files outFileDir: ${this.outFileDir}`);
        // 根据解压后的文件所属沙箱目录，获取解压后的文件列表
        this.getFileListData(this.outFileDir);
      } else {
        logger.error(TAG, 'Decompress Files failed!');
      }
      // TODO：知识点：主线程使用terminate()销毁Worker线程。
      workerInstance.terminate();
    }
    /**
     * TODO：知识点：主线程使用postMessage()向worker线程发送消息。
     * 主线程使用postMessage()向worker线程发送应用沙箱路径和压缩文件名称。
     */
    workerInstance.postMessage({ pathDir: this.pathDir, rawfileZipName: rawfileZipName });
  }

  // 将项目目录rawfile下的压缩文件写入到应用的沙箱目录，用于后续介绍解压操作。
  initZip(rawfileZipName: string) {
    // 使用getRowFileContent接口以字节数组的形式获取到rawfile中的文件内容。
    this.context.resourceManager.getRawFileContent(rawfileZipName, (error: BusinessError, value: Uint8Array) => {
      if (error) {
        logger.error(TAG, `getRawFileContent failed, error message: ${error.message}, error code: ${error.code}`);
      } else {
        const rawFile: Uint8Array = value;
        this.pathDir = this.context.filesDir; // 获取应用沙箱目录
        logger.info(TAG, `Application Sandbox Directory: ${this.pathDir}`);
        this.rawfilePath = `${this.pathDir}/${rawfileZipName}`; // 设置rawfile压缩文件的应用沙箱路径
        const file = fs.openSync(this.rawfilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE); // 在指定路径以同步方法打开或创建文件
        // 使用fs.write接口将字节数组形式的rawfile的文件内容写入到指定沙箱路径filePath中
        fs.write(file.fd, rawFile.buffer).then((writeLen: number) => {
          logger.info(TAG, `write data to file succeed and size is: ${writeLen}`);
        }).catch((err: BusinessError) => {
          logger.error(TAG, `write data to file failed with error message: ${err.message}, error code: ${err.code}`);
        }).finally(() => {
          logger.info(TAG, 'write finished');
          fs.closeSync(file); // 以同步方法关闭文件。
        });
      }
    });
  }

  // 获取解压后的文件列表
  getFileListData(outFileDir: string) {
    // TODO：知识点：使用fs.listFile接口获取解压得到的沙箱目录下的所有文件名。
    fs.listFile(outFileDir).then((fileNames: Array<string>) => {
      this.fileListData.clearData(); // 清空上一次获取的列表
      for (let i = 0; i < fileNames.length; i++) {
        this.fileListData.pushData(new FileItem(fileNames[i], `${outFileDir}/${fileNames[i]}`));
      }
    }).catch((err: BusinessError) => {
      logger.error('list file failed with error message: ${err.message}, error code: ${err.code}');
    });
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text($r('app.string.file_decompress'))
            .fontColor($r('app.color.ohos_id_color_background'))
            .fontWeight(FontWeight.Bolder)
            .fontSize($r('app.integer.title_fontsize'))
          Text($r('app.string.sub_title'))
            .fontColor($r('app.color.ohos_id_color_background'))
        }
        .width($r('app.integer.title_width'))
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_files_compress'))
          .width($r('app.integer.top_bar_icon_width'))
          .height($r('app.integer.top_bar_icon_width'))
      }
      .width('100%')
      .height($r('app.integer.top_bar_height'))
      .padding($r('app.integer.top_bar_padding'))
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      .linearGradient({
        direction: GradientDirection.Top, // 渐变方向
        repeating: true, // 渐变颜色是否重复
        colors: [[$r('app.color.linear_gradient_start'), LINEAR_GRADIENT_START], [$r('app.color.linear_gradient_end'), LINEAR_GRADIENT_END]] // 数组末尾元素占比小于1时满足重复着色效果
      })

      // 压缩文件组件
      Row() {
        Image($r('app.media.ic_files_compress'))
          .width($r('app.integer.file_icon_width'))
          .height($r('app.integer.file_icon_width'))
          .margin({ right: $r('app.string.ohos_id_card_margin_start') })
        Text(this.rawfileZipName)
          .fontSize($r('app.string.ohos_id_text_size_body1'))
          .layoutWeight(LAYOUT_WEIGHT)
        Button($r('app.string.decompress'))
          .fontWeight(FontWeight.Bold)
          .type(ButtonType.Normal)
          .width($r('app.integer.decompress_button_width'))
          .height($r('app.integer.decompress_button_height'))
          .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
          .onClick(() => {
            this.decompressFileByWorker(this.rawfileZipName);
          })
      }
      .padding($r('app.string.ohos_id_card_padding_start'))
      .backgroundColor($r('app.color.ohos_id_color_background'))

      Divider()

      Text($r('app.string.decompressed_files'))
        .textAlign(TextAlign.Start)
        .fontSize($r('app.string.ohos_id_text_size_headline'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding($r('app.string.ohos_id_card_padding_start'))
        .backgroundColor($r('app.color.decompress_result_background'))

      Divider()

      // 解压后的文件列表组件
      List() {
        // 性能：使用LazyForEach加载文件列表，https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/lazyforeach_optimization.md/
        LazyForEach(this.fileListData, (item: FileItem) => {
          ListItem() {
            FileListItem({ item: item })
          }
        }, (item: FileItem) => JSON.stringify(item))
      }
      .cachedCount(CACHED_COUNT)
      .width('100%')
      .backgroundColor($r('app.color.ohos_id_color_background'))
      .height($r('app.integer.decompress_list_height'))
      .layoutWeight(LAYOUT_WEIGHT)
      .divider({
        strokeWidth: $r('app.integer.stroke_width'),
        color: $r('app.color.ohos_id_color_sub_background'),
        startMargin: $r('app.string.ohos_id_card_margin_start'),
        endMargin: $r('app.string.ohos_id_card_margin_start')
      }) // 每行之间的分界线
      .borderRadius({
        bottomLeft: $r('app.string.ohos_id_corner_radius_default_m'),
        bottomRight: $r('app.string.ohos_id_corner_radius_default_m')
      })

    }
    .height('100%')
    .padding($r('app.string.ohos_id_card_padding_start'))
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
  }
}

@Reusable
@Component
struct FileListItem {
  @State item: FileItem = new FileItem('', '');

  aboutToReuse(params: Record<string, FileItem>): void {
    this.item = params.item;
  }

  build() {
    Row() {
      Image($r('app.media.ic_files_documents'))
        .width($r('app.integer.file_icon_width'))
        .height($r('app.integer.file_icon_width'))
        .margin({ right: $r('app.string.ohos_id_card_margin_start') })
      Text(this.item.fileName)
        .fontSize($r('app.string.ohos_id_text_size_body1'))
    }
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getDecompressFileView(): void {
  DecompressFileView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.DECOMPRESS_FILE, wrapBuilder(getDecompressFileView));

