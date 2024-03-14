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

import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { ColorHsv, ColorRgb, ColorUtils } from './ColorUtils';

const resourceMgs: resourceManager.ResourceManager = getContext(this).resourceManager;
const PIXEL_MAP_SIZE_WIDTH: number = 40;
const PIXEL_MAP_SIZE_HEIGHT: number = 40;

/**
 * 图片转换为PixelMap对象
 * @param icon 图片地址，模拟数据存放于rawfile文件夹中
 * @returns 图片转换的PixelMap对象
 */
export async function image2PixelMap(icon: string): Promise<image.PixelMap> {
  // 读取rawfile文件夹下的文件
  const rawFileDescriptor: resourceManager.RawFileDescriptor = resourceMgs.getRawFdSync(icon);
  const imageSource: image.ImageSource = image.createImageSource(rawFileDescriptor);
  // 通过ImageSource对象创建PixelMap对象，使用BGRA_8888格式，由4个字节表示一个像素
  const pixelMap: Promise<PixelMap> = imageSource.createPixelMap({
    editable: false,
    desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
    // 高性能知识点：经测试，将图片的宽和高设置为40像素时，既可以保证提取颜色的准确性，也可以保证计算颜色的速度。
    desiredSize: { width: PIXEL_MAP_SIZE_WIDTH, height: PIXEL_MAP_SIZE_HEIGHT }
  })
  return pixelMap;
}

/**
 * 查找数组中出现次数最多的像素
 * @param allPixels 像素数组
 * @returns 出现次数最多的像素
 */
export function findMaxPixel(allPixels: number[]): number {
  // 遍历数组，将像素放到一个Map中，key是像素值，value是该像素值出现的次数
  const map: Map<number, number> = new Map();
  allPixels.forEach((pixel: number) => {
    if (map.has(pixel)) {
      map.set(pixel, map.get(pixel)! + 1);
    } else {
      map.set(pixel, 1);
    }
  })
  // 查找出现次数最多的像素
  let maxPixel: number = 0;
  let maxTimes: number = 0;
  map.forEach((value: number, key: number) => {
    if (value >= maxTimes) {
      maxTimes = value;
      maxPixel = key;
    }
  })
  return maxPixel;
}

/**
 * 修改HSV格式的颜色值，可根据业务需求或者UI设计自行修改S和V的值，此处只举例进行说明
 * @param color HSV格式的颜色
 */
export function modifySVValue(color: ColorHsv): void {
  if (color.hue > 0 && color.hue <= 60) {
    color.saturation = 0.12;
    color.value = 0.93;
  } else if (color.hue > 60 && color.hue <= 190) {
    color.saturation = 0.08;
    color.value = 0.91;
  } else if (color.hue > 190 && color.hue <= 270) {
    color.saturation = 0.1;
    color.value = 0.93;
  } else {
    color.saturation = 0.08;
    color.value = 0.93;
  }
}

/**
 * 遍历所有像素，并放到一个数组中
 * @param pixelMap 图片的PixelMap对象
 * @returns 包含图片所有像素的数组
 */
export async function traverseAllPixel(pixelMap: image.PixelMap): Promise<number[]> {
  // PixelMap对象使用BGRA_8888格式，由4个字节表示一个像素，并且宽和高都设置为40，所以此处ArrayBuffer的length就是40*40*4
  const pixelArrayBuffer: ArrayBuffer = new ArrayBuffer(40 * 40 * 4);
  // 将PixelMap对象读入ArrayBuffer中
  await pixelMap.readPixelsToBuffer(pixelArrayBuffer);
  const allPixels: number[] = [];
  // ArrayBuffer是一个二进制的数组，无法直接读取内容，需要转换为整型数组才可以正常使用，此处使用Uint8Array（8 位无符号整型数组）
  const unit8Pixels: Uint8Array = new Uint8Array(pixelArrayBuffer);
  // 遍历unit8Pixels，取出每个像素的red、green、blue、alpha颜色值，放到一个ColorRgb对象中，然后将ColorRgb转换为数字，放入数组中
  for (let i = 0; i < unit8Pixels.length; i += 4) {
    // 如果是透明色，则不放入数组中，否则可能导致计算出来的出现次数最多的像素是透明色
    if (unit8Pixels[i] === 0 && unit8Pixels[i+1] === 0 && unit8Pixels[i+2] === 0 && unit8Pixels[i+3] === 0) {
      continue;
    }
    // BGRA_8888格式，B表示Blue，G表示Green，R表示Red，A表示透明度，此处根据顺序提取B、R、G、A
    const rgb: ColorRgb = {
      red: unit8Pixels[i+2],
      green: unit8Pixels[i+1],
      blue: unit8Pixels[i],
      alpha: unit8Pixels[i+3]
    }
    // 高性能知识点：直接将ColorRgb放入数组或者Map中会影响计算出现次数最多的像素的速度，所以需要使用rgbToNumber方法转换为整数
    allPixels.push(ColorUtils.rgbToNumber(rgb));
  }
  return allPixels;
}