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
import fs from '@ohos.file.fs'; // 导入文件管理模块
import fileUri from "@ohos.file.fileuri"; // 导入文件URI模块
import image from '@ohos.multimedia.image'; // 导入Image模块
import resourceManager from '@ohos.resourceManager'; // 导入资源管理模块
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

/**
 * 图片压缩实现步骤
 * 1.获取图片。从资源管理器获取要压缩的图片，创建ImageSource实例，设置解码参数DecodingOptions，使用createPixelMap获取PixelMap图片对象。
 * 2.图片压缩。调用自定义compressedImage方法，传入要压缩图片的pixelMap和指定图片的压缩目标大小。先判断设置图片质量参数quality为0时，
 * packing能压缩到的图片最小字节大小是否满足指定的图片压缩大小。如果满足，则使用packing方式二分查找最接近指定图片压缩目标大小的quality
 * 来压缩图片。如果不满足，则使用scale对图片先进行缩放，采用while循环每次递减0.4倍缩放图片，再用packing（图片质量参数quality设置0）获取压缩
 * 图片大小，最终查找到最接近指定图片压缩目标大小的缩放倍数的图片压缩数据。
 * 3.保存图片。获取最终图片压缩数据compressedImageData，保存图片。
 */

const TAG = 'IMAGE_COMPRESSION';
const SPACE_TEN: number = 10; // 组件间距
const BYTE_CONVERSION: number = 1024; // 字节转换

// 压缩后的图片信息类，用于刷新显示压缩后的图片和图片字节长度
class CompressedImageInfo {
  imageUri: string = ""; // 压缩后图片保存位置的uri
  imageByteLength: number = 0; // 压缩后图片字节长度
}

/**
 * 图片压缩，保存
 * @param sourcePixelMap：原始待压缩图片的PixelMap对象
 * @param maxCompressedImageSize：指定图片的压缩目标大小，单位kb
 * @returns compressedImageInfo：返回最终压缩后的图片信息
 */
async function compressedImage(sourcePixelMap: PixelMap, maxCompressedImageSize: number): Promise<CompressedImageInfo> {
  // 创建图像编码ImagePacker对象
  let imagePackerApi = image.createImagePacker();
  // 定义图片质量参数
  let imageQuality = 0;
  // 设置编码输出流和编码参数。图片质量参数quality范围0-100。
  let packOpts: image.PackingOption = { format: "image/jpeg", quality: imageQuality };
  // 通过PixelMap进行编码。compressedImageData为打包获取到的图片文件流。
  let compressedImageData: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
  // 压缩目标图像字节长度
  let maxCompressedImageByte = maxCompressedImageSize * BYTE_CONVERSION;
  // TODO 知识点：图片压缩。先判断设置图片质量参数quality为0时，packing能压缩到的图片最小字节大小是否满足指定的图片压缩大小。如果满足，则使用packing方式二分查找最接近指定图片压缩目标大小的quality来压缩图片。如果不满足，则使用scale对图片先进行缩放，采用while循环每次递减0.4倍缩放图片，再用packing（图片质量参数quality设置0）获取压缩图片大小，最终查找到最接近指定图片压缩目标大小的缩放倍数的图片压缩数据。
  if (maxCompressedImageByte > compressedImageData.byteLength) {
    // 使用packing二分压缩获取图片文件流
    compressedImageData = await packingImage(compressedImageData, sourcePixelMap, imageQuality, maxCompressedImageByte);
  } else {
    // 使用scale对图片先进行缩放，采用while循环每次递减0.4倍缩放图片，再用packing（图片质量参数quality设置0）获取压缩图片大小，最终查找到最接近指定图片压缩目标大小的缩放倍数的图片压缩数据
    let imageScale = 1; // 定义图片宽高的缩放倍数，1表示原比例。
    let reduceScale = 0.4; // 图片缩小倍数
    // 判断压缩后的图片大小是否大于指定图片的压缩目标大小，如果大于，继续降低缩放倍数压缩。
    while (compressedImageData.byteLength > maxCompressedImageByte) {
      if (imageScale > 0) {
        // 性能知识点: 由于scale会直接修改图片PixelMap数据，所以不适用二分查找scale缩放倍数。这里采用循环递减0.4倍缩放图片，来查找确定最适
        // 合的缩放倍数。如果对图片压缩质量要求不高，建议调高每次递减的缩放倍数reduceScale，减少循环，提升scale压缩性能。
        imageScale = imageScale - reduceScale; // 每次缩放倍数减0.4
        // 使用scale对图片进行缩放
        await sourcePixelMap.scale(imageScale, imageScale);
        // packing压缩
        compressedImageData = await packing(sourcePixelMap, imageQuality);
      } else {
        // imageScale缩放小于等于0时，没有意义，结束压缩。这里不考虑图片缩放倍数小于reduceScale的情况。
        break;
      }
    }
  }
  // 保存图片，返回压缩后的图片信息。
  let compressedImageInfo: CompressedImageInfo = await saveImage(compressedImageData);
  return compressedImageInfo;
}

/**
 * packing压缩
 * @param sourcePixelMap：原始待压缩图片的PixelMap
 * @param imageQuality：图片质量参数
 * @returns data：返回压缩后的图片数据
 */
async function packing(sourcePixelMap: PixelMap, imageQuality: number): Promise<ArrayBuffer> {
  let imagePackerApi = image.createImagePacker();
  let packOpts: image.PackingOption = { format: "image/jpeg", quality: imageQuality };
  let data: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
  return data;
}

/**
 * packing二分方式循环压缩
 * @param compressedImageData：图片压缩的ArrayBuffer
 * @param sourcePixelMap：原始待压缩图片的PixelMap
 * @param imageQuality：图片质量参数
 * @param maxCompressedImageByte：压缩目标图像字节长度
 * @returns compressedImageData：返回二分packing压缩后的图片数据
 */
async function packingImage(compressedImageData: ArrayBuffer, sourcePixelMap: PixelMap, imageQuality: number, maxCompressedImageByte: number): Promise<ArrayBuffer> {
  // 图片质量参数范围为0-100，这里以10为最小二分单位创建用于packing二分图片质量参数的数组。
  let packingArray: number[] = [];
  let dichotomyAccuracy = 10;
  // 性能知识点: 如果对图片压缩质量要求不高，建议调高最小二分单位dichotomyAccuracy，减少循环，提升packing压缩性能。
  for (let i = 0; i <= 100; i += dichotomyAccuracy) {
    packingArray.push(i);
  }
  let left = 0; // 定义二分搜索范围的左边界
  let right = packingArray.length - 1; // 定义二分搜索范围的右边界
  // 二分压缩图片
  while (left <= right) {
    let mid = Math.floor((left + right) / 2); // 定义二分搜索范围的中间位置
    imageQuality = packingArray[mid]; // 获取二分中间位置的图片质量值
    // 根据传入的图片质量参数进行packing压缩，返回压缩后的图片文件流数据。
    compressedImageData = await packing(sourcePixelMap, imageQuality);
    // 判断查找一个尽可能接近但不超过压缩目标的压缩大小
    if (compressedImageData.byteLength <= maxCompressedImageByte) {
      // 二分目标值在右半边，继续在更高的图片质量参数（即mid + 1）中搜索
      left = mid + 1;
      // 判断mid是否已经二分到最后，如果二分完了，退出
      if (mid === packingArray.length - 1) {
        break;
      }
      // 获取下一次二分的图片质量参数（mid+1）压缩的图片文件流数据
      compressedImageData = await packing(sourcePixelMap, packingArray[mid + 1]);
      // 判断用下一次图片质量参数（mid+1）压缩的图片大小是否大于指定图片的压缩目标大小。如果大于，说明当前图片质量参数（mid）压缩出来的
      // 图片大小最接近指定图片的压缩目标大小。传入当前图片质量参数mid，得到最终目标图片压缩数据。
      if (compressedImageData.byteLength > maxCompressedImageByte) {
        compressedImageData = await packing(sourcePixelMap, packingArray[mid]);
        break;
      }
    } else {
      // 目标值不在当前范围的右半部分，将搜索范围的右边界向左移动，以缩小搜索范围并继续在下一次迭代中查找左半部分。
      right = mid - 1;
    }
  }
  return compressedImageData;
}

/**
 * 图片保存
 * @param compressedImageData：压缩后的图片数据
 * @returns compressedImageInfo：返回压缩后的图片信息
 */
async function saveImage(compressedImageData: ArrayBuffer): Promise<CompressedImageInfo> {
  let context: Context = getContext();
  // 定义要保存的压缩图片uri。afterCompressiona.jpeg表示压缩后的图片。
  let compressedImageUri: string = context.filesDir + '/' + 'afterCompressiona.jpeg';
  try {
    let res = fs.accessSync(compressedImageUri);
    if (res) {
      // 如果图片afterCompressiona.jpeg已存在，则删除
      fs.unlinkSync(compressedImageUri);
    }
  } catch (err) {
    logger.error(TAG, `AccessSync failed with error message: ${err.message}, error code: ${err.code}`);
  }
  // TODO 知识点：保存图片。获取最终图片压缩数据compressedImageData，保存图片。
  // 压缩图片数据写入文件
  let file: fs.File = fs.openSync(compressedImageUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  fs.writeSync(file.fd, compressedImageData);
  fs.closeSync(file);
  // 获取压缩图片信息
  let compressedImageInfo: CompressedImageInfo = new CompressedImageInfo();
  compressedImageInfo.imageUri = compressedImageUri;
  compressedImageInfo.imageByteLength = compressedImageData.byteLength;
  return compressedImageInfo;
}

@Component
export struct ImageCompression {
  @State compressedImageSrc: string | Resource = ''; // 压缩后的图片路径
  @State beforeCompressionSize: string = ''; // 压缩前的图片大小,单位kb
  @State afterCompressionSize: string = ''; // 压缩后的图片大小,单位kb
  private sourceImageByteLength: number = 0; // 压缩前的原图字节长度
  private compressedByteLength: number = 0; // 压缩后的图片字节长度
  private maxCompressedImageSize: number = 0; // 指定图片压缩目标大小，单位kb
  private context: Context = getContext(this);

  // 获取压缩前图片大小，用于页面上图片显示。
  aboutToAppear(): void {
    const context: Context = getContext(this);
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    // 获取待压缩的图片
    resourceMgr.getRawFileContent('beforeCompression.jpeg').then((fileData: Uint8Array) => {
      // 获取图片的ArrayBuffer
      let buffer = fileData.buffer.slice(0);
      this.sourceImageByteLength = buffer.byteLength;
      this.beforeCompressionSize = (this.sourceImageByteLength / BYTE_CONVERSION).toFixed(1);
    }).catch((err: BusinessError) => {
      logger.error(TAG, `Failed to get RawFileContent with error message: ${err.message}, error code: ${err.code}`);
    });
  }

  /**
   * 从rawfile中获取需要压缩的图片beforeCompression.jpeg，压缩
   */
  imageCompression(): void {
    // TODO 知识点：获取图片。从资源管理器获取要压缩的图片，创建ImageSource实例，设置解码参数DecodingOptions，使用createPixelMap获取PixelMap图片对象。
    // 获取resourceManager资源管理器
    const resourceMgr: resourceManager.ResourceManager = this.context.resourceManager;
    // 获取资源管理器后，再调用resourceMgr.getRawFileContent()获取资源文件的ArrayBuffer。
    resourceMgr.getRawFileContent('beforeCompression.jpeg').then((fileData: Uint8Array) => {
      // 获取图片的ArrayBuffer
      const buffer = fileData.buffer.slice(0);
      // 创建ImageSource实例
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      // 设置解码参数DecodingOptions，解码获取PixelMap图片对象。
      let decodingOptions: image.DecodingOptions = {
        editable: true, // 是否可编辑。当取值为false时，图片不可二次编辑，如crop等操作将失败。
        desiredPixelFormat: 3, // 解码的像素格式。3表示RGBA_8888。
      }
      // 创建pixelMap
      imageSource.createPixelMap(decodingOptions).then((originalPixelMap: image.PixelMap) => {
        // 压缩图片
        compressedImage(originalPixelMap, this.maxCompressedImageSize).then((showImage: CompressedImageInfo) => {
          // 获取压缩后的图片信息
          this.compressedImageSrc = fileUri.getUriFromPath(showImage.imageUri);
          this.compressedByteLength = showImage.imageByteLength;
          this.afterCompressionSize = (this.compressedByteLength / BYTE_CONVERSION).toFixed(1);
        })
      }).catch((err: BusinessError) => {
        logger.error(TAG, `Failed to create PixelMap with error message: ${err.message}, error code: ${err.code}`);
      });
    }).catch((err: BusinessError) => {
      logger.error(TAG, `Failed to get RawFileContent with error message: ${err.message}, error code: ${err.code}`);
    });
  }

  build() {
    Column({ space: SPACE_TEN }) {
      Row({ space: SPACE_TEN }) {
        Text($r('app.string.max_compression_image_size')).fontSize($r('app.integer.font_size_25'))
        TextInput()
          .type(InputType.Number)
          .fontSize($r('app.integer.font_size_25'))
          .width($r('app.string.text_input_width'))
          .onChange((value: string) => {
            this.maxCompressedImageSize = Number(value);
          })
      }

      Button($r('app.string.image_compression')).onClick(() => {
        if (this.maxCompressedImageSize === 0) {
          AlertDialog.show({
            message: $r('app.string.prompt_enter_value_greater_than_0'),
            alignment: DialogAlignment.Center
          });
          return;
        }
        if (this.maxCompressedImageSize * BYTE_CONVERSION > this.sourceImageByteLength) {
          AlertDialog.show({
            message: $r('app.string.prompt_not_require_compression'),
            alignment: DialogAlignment.Center
          });
          return;
        }
        // 重置压缩后的图片路径
        this.compressedImageSrc = '';
        // 从rawfile中获取图片，图片压缩
        this.imageCompression();
      }).fontSize($r('app.integer.font_size_25')).width($r('app.string.button_width'))

      Row() {
        Text($r('app.string.image_size_before_compression'))
          .fontSize($r('app.integer.font_size_25'))
        Text(this.beforeCompressionSize)
          .fontSize($r('app.integer.font_size_25'))
      }

      Image($rawfile('beforeCompression.jpeg'))
        .width($r('app.string.image_width'))
        .height($r('app.string.image_height'))

      Row() {
        Text($r('app.string.image_size_after_compression'))
          .fontSize($r('app.integer.font_size_25'))
        Text(this.afterCompressionSize)
          .fontSize($r('app.integer.font_size_25'))
      }

      Image(this.compressedImageSrc)
        .width($r('app.string.image_width'))
        .height($r('app.string.image_height'))
    }.alignItems(HorizontalAlign.Start).padding($r('app.integer.column_padding'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageCompression(): void {
  ImageCompression();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.IMAGE_COMPRESSION, wrapBuilder(getImageCompression));