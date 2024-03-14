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
 * RGB颜色类型
 */
export interface ColorRgb {
  // 红色（Red）
  red: number;

  // 绿色（Green）
  green: number;

  // 蓝色（Blue）
  blue: number;

  // 透明度
  alpha: number;
}

/**
 * HSV颜色类型
 */
export interface ColorHsv {
  // 色调
  hue: number;

  // 饱和度
  saturation: number;

  // 明度
  value: number;

  // 透明度
  alpha: number;
}

// RGB颜色最大值
const MAX_RGB_VALUE: number = 255.0;

export class ColorUtils {
  /**
   * RGB格式转换为HSV格式，公式参考resources/base/media/rgb_to_hsv.png
   * @param color RGB像素值
   * @returns HSV像素值
   */
  public static rgb2hsv(color: ColorRgb): ColorHsv {
    // RGB颜色取值范围是0~255，需要转换为0~1的浮点数
    const red: number = color.red / MAX_RGB_VALUE;
    const green: number = color.green / MAX_RGB_VALUE;
    const blue: number = color.blue / MAX_RGB_VALUE;

    const max: number = Math.max(red, green, blue);
    const min: number = Math.min(red, green, blue);
    const delta: number = max - min;

    // 色调
    let hue: number = 0;
    // 饱和度
    let saturation: number = 0;
    // 明度
    let value: number = 0;
    // 计算hue值
    if (max === min) {
      hue = 0;
    } else if (Math.abs(max - red) < Number.EPSILON) {
      hue = (green >= blue ? ((green - blue) / delta) * 60 : ((green - blue) / delta) * 60 + 360);
    } else if (Math.abs(max - green) < Number.EPSILON) {
      hue = (((blue - red) / delta) + 2) * 60;
    } else if (Math.abs(max - blue) < Number.EPSILON) {
      hue = (((red - green) / delta) + 4) * 60;
    }
    // 计算saturation值
    saturation = (max === 0 ? 0 : delta / max);
    // 计算value值
    value = max;

    return {
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: color.alpha
    }
  }

  /**
   * HSV格式转换为RGB格式，公式可参考resources/base/media/hsv_to_rgb.png
   * @param color HSV像素值
   * @returns RGB像素值
   */
  public static hsv2rgb(color: ColorHsv): ColorRgb {
    // hue取值范围是0~360°，每60°为一个区间，每个区间中RGB计算方式不同
    const h60: number = color.hue / 60;
    // 向下取整
    const h60f: number = Math.floor(h60);
    const hi: number = h60f % 6;
    const f: number = h60 - h60f;
    // 计算不同hue区间里面的RGB值
    const p: number = color.value * (1 - color.saturation);
    const q: number = color.value * (1 - f * color.saturation);
    const t: number = color.value * (1 - (1 - f) * color.saturation);

    let red: number = 0.0;
    let green: number = 0.0;
    let blue: number = 0.0;
    // 根据区间，计算RGB的值
    if (hi === 0) {
      red = color.value;
      green = t;
      blue = p;
    } else if (hi === 1) {
      red = q;
      green = color.value;
      blue = p;
    } else if (hi === 2) {
      red = p;
      green = color.value;
      blue = t;
    } else if (hi === 3) {
      red = p;
      green = q;
      blue = color.value;
    } else if (hi === 4) {
      red = t;
      green = p;
      blue = color.value;
    } else if (hi === 5) {
      red = color.value;
      green = p;
      blue = q;
    }
    // RGB取值范围是0~255，需要通过计算
    return {
      red: Math.floor(red * MAX_RGB_VALUE),
      green: Math.floor(green * MAX_RGB_VALUE),
      blue: Math.floor(blue * MAX_RGB_VALUE),
      alpha: color.alpha
    }
  }

  /**
   * RGB颜色转为整数值
   * @param color RGB像素值
   * @returns 整数
   */
  public static rgbToNumber(color: ColorRgb): number {
    return ((color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue);
  }

  /**
   * 整数值转为RGB颜色值
   * @param color 整数
   * @returns RGB格式像素
   */
  public static numberToRgb(color: number): ColorRgb {
    return {
      red: (color & 0xFF0000) >> 16,
      green: (color & 0xFF00) >> 8,
      blue: (color & 0xFF),
      alpha: (color & 0xFF000000) >> 24
    }
  }
}