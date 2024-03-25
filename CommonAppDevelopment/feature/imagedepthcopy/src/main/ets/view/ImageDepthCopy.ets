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

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/base';
import image from '@ohos.multimedia.image';                  // 导入Image模块
import resourceManager from '@ohos.resourceManager';         // 导入资源管理模块
import { CropTasks, TaskData, cropTaskDatas } from '../model/AdjustData';
import { savePixelMap } from '../util/FileUtil';
import { copyPixelMap } from '../util/CopyObj';
import { ImageCropConstants } from '../constants/ImageCropConstants';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * PixelMap深拷贝实现步骤
 * 1.获取源图片PixelMap。从资源管理器获取图片，创建ImageSource实例并保存，使用createPixelMap创建BGRA_8888格式的PixelMap图片对象。
 * 2.创建目标图片PixelMap。通过readPixelsToBuffer读取源PixelMap到ArrayBuffer，再通过createPixelMap得到目标PixelMap。
 * 3.图片裁剪。通过PixelMap的crop方法进行裁剪。
 * 4.将当前的图片数据进行保存。
 */
const TAG = 'IMAGE_DEPTHCOPY';

@Component
export struct ImageDepthCopy {
  private imageSource: image.ImageSource | undefined = undefined;
  private pixelMapSrc: PixelMap | undefined | null = undefined;     // 源PixelMap
  private columnSpace: number = 24;                                 // 内容相隔距离
  @State pixelMapDst: PixelMap | undefined | null = undefined;      // 目标PixelMap
  @State cropIndex: number = 0;                                     // 裁剪选项索引
  @State currentCropTask: number = CropTasks.NONE;                  // 裁剪任务

  /**
   * 保存图片
   */
  async onSave(): Promise<void> {
    if (this.pixelMapDst !== undefined && this.pixelMapDst !== null) {
      try {
        promptAction.showDialog({
          alignment: DialogAlignment.Center,
          isModal: false,
          message: $r('app.string.image_depthcopy_save_confirm'),
          buttons: [
            {
              text: $r('app.string.image_depthcopy_confirm'),
              color: $r('app.color.confirm')
            },
            {
              text: $r('app.string.image_depthcopy_cancel'),
              color: $r('app.color.cancel')
            }
          ]
        }, async (err, data) => {
          if (err) {
            logger.error(TAG, 'showDialog err: ' + err);
            return;
          }
          if (data.index === 0) {
            // 确认保存图片
            const uri: string = await savePixelMap(getContext(this), this.pixelMapDst!);
            const strMsg: string = getContext(this)
              .resourceManager
              .getStringSync($r('app.string.image_depthcopy_savepath').id) + uri;
            logger.info(TAG, `imageInfo SavePath is ` + uri);
            promptAction.showDialog({
              message: strMsg,
              alignment: DialogAlignment.Center
            });
          }
        });
      } catch (error) {
        const message = (error as BusinessError).message;
        const code = (error as BusinessError).code;
        logger.error(TAG, 'showDialog args error code is' + code + ', message is' + message);
      }
    }
  }

  /**
   * 图片裁剪
   */
  async cropImage(proportion: number): Promise<void> {
    if (!this.pixelMapSrc) {
      logger.error(TAG, `pixelMapSrc is null`);
      return;
    }
    // TODO 知识点：通过readPixelsToBuffer拷贝到PixelMap对象
    const pixelMapTemp = await copyPixelMap(this.pixelMapSrc);
    const imageInfo: image.ImageInfo = await pixelMapTemp.getImageInfo();
    if (!imageInfo) {
      logger.error(TAG, `imageInfo is null`);
      return;
    }
    let imageHeight: number = imageInfo.size.height;
    let imageWith: number = imageInfo.size.width;
    if (proportion === ImageCropConstants.ONE_ONE) {
      if (imageHeight > imageWith) {
        imageHeight = imageWith;
      } else {
        imageWith = imageHeight;
      }
    }
    try {
      logger.info(TAG, `imageInfo imageHeight = ${JSON.stringify(imageHeight / proportion)}, imageWith = ${JSON.stringify(imageWith)}`);
      // PixelMap按比例裁剪
      await pixelMapTemp.crop({
        size: { height: imageHeight / proportion, width: imageWith },
        x: 0,
        y: 0
      });
      this.pixelMapDst = pixelMapTemp;
    } catch (error) {
      logger.error(TAG, `imageInfo crop error = ${JSON.stringify(error)}`);
    }
    logger.info(TAG, `cropImage success`);
  }

  async aboutToAppear(): Promise<void> {
    const context: Context = getContext(this);
    // 获取resourceManager资源管理
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    // 获取rawfile中的图片资源
    const fileData: Uint8Array = await resourceMgr.getRawFileContent(ImageCropConstants.RAWFILE_PICPATH);
    // 获取图片的ArrayBuffer
    const buffer = fileData.buffer.slice(fileData.byteOffset, fileData.byteLength + fileData.byteOffset);
    // 保存用于恢复原图的imageSource
    this.imageSource = image.createImageSource(buffer);
    // TODO 知识点： 创建源图片的用于深拷贝的PixelMap，因readPixelsToBuffer输出为BGRA_8888。故此处desiredPixelFormat需为BGRA_8888
    const decodingOptions: image.DecodingOptions = {
      editable: false,
      desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
    }
    // 保存用于深拷贝的pixelMapgit

    this.pixelMapSrc = await this.imageSource.createPixelMap(decodingOptions);
    // TODO 知识点： 通过readPixelsToBuffer进行深拷贝
    this.pixelMapDst = await copyPixelMap(this.pixelMapSrc!);
  }

  // 底部裁剪选项
  @Builder
  getCropTool() {
    Row() {
      List() {
        // TODO: 性能知识点：使用ForEach组件循环渲染数据
        ForEach(cropTaskDatas, (item: TaskData, index: number) => {
          ListItem() {
            Column() {
              Image(item.image)
                .width($r('app.float.size_30'))
                .height($r('app.float.size_30'))
                .margin({ top: $r('app.float.size_5') })
              Text(item.text)
                .fontColor(Color.White)
                .fontSize($r('app.float.size_14'))
                .margin({ top: $r('app.float.size_5'), bottom: $r('app.float.size_5') })
            }
            .backgroundColor(this.cropIndex === index ? $r('app.color.edit_image_public_background') : $r('app.color.edit_image_crop_select'))
            .justifyContent(FlexAlign.Center)
            .height('50%')
            .width('25%')
            .onClick(async () => {
              if (item.task !== undefined) {
                // 与当前裁剪选项一样，不处理
                if (item.task === this.currentCropTask) {
                  return;
                }
                this.currentCropTask = item.task;
              }
              this.cropIndex = index;
              if (this.currentCropTask === CropTasks.ORIGIN) {
                // 原图
                this.pixelMapDst = await this.imageSource!.createPixelMap();
              } else if (this.currentCropTask === CropTasks.ONE_ONE) {
                await this.cropImage(ImageCropConstants.ONE_ONE);
                console.log(TAG + 'CropTasks  this.cropImage(1)' + this.currentCropTask)
              } else if (this.currentCropTask === CropTasks.THREE_FOUR) {
                await this.cropImage(ImageCropConstants.THREE_FOUR);
                console.log(TAG + 'CropTasks  cropImage(4 / 3)==' + this.currentCropTask)
              } else if (this.currentCropTask === CropTasks.NINE_SIXTH) {
                await this.cropImage(ImageCropConstants.NINE_SIXTH);
                console.log(TAG + 'CropTasks  (16 / 9)==' + this.currentCropTask);
              }
            })
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .height('18%')
      .width('100%')
    }.backgroundColor(Color.Black)
    .width('100%')
  }

  build() {
    Column() {
      Row() {
        Blank()
        // 保存功能
        Row({ space: this.columnSpace }) {
          Image($r('app.media.ic_public_save'))
            .height($r('app.float.size_32'))
            .width($r('app.float.size_32'))
            .id('Save')
            .onClick(() => {
              this.onSave();
            })
        }.padding({ right: $r('app.float.size_10'), top: $r('app.float.size_10') })
      }.backgroundColor(Color.Black)
      .width('100%')
      .padding({ left: $r('app.float.size_14') })
      .margin({ top: $r('app.float.size_20') });
      // 图片编辑部分
      Row() {
        Image(this.pixelMapDst).objectFit(ImageFit.None)
      }.width('100%')
      .height('50%')
      .backgroundColor(Color.Black)

      // 裁剪选项
      this.getCropTool();
    }
    .padding($r('app.integer.padding_12'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageDepthCopyView(): void {
  ImageDepthCopy();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_DEPTH_COPY, wrapBuilder(getImageDepthCopyView));
