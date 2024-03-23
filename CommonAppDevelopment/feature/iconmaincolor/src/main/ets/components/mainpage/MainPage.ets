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

import image from '@ohos.multimedia.image';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { ColorHsv, ColorRgb, ColorUtils } from '../utils/ColorUtils';
import { findMaxPixel, image2PixelMap, modifySVValue, traverseAllPixel } from '../utils/ImageUtils';

/**
 * 实现步骤：
 * 1.将模拟数据放入列表中
 * 2.遍历模拟数据
 * 3.将模拟数据中的icon图标转换为PixelMap
 * 4.遍历PixelMap，将所有的像素放到一个数组中
 * 5.遍历数组，找出出现次数最多的像素
 * 6.将像素转换为RGB颜色格式
 * 7.将RGB颜色格式转换为HSV颜色格式
 * 8.调整HSV颜色格式中的参数
 * 9.将HSV颜色格式转换为RGB格式
 * 10.将RGB颜色格式转换为数字，放入模拟数据中
 * 11.在ListItem组件中，设置子组件的背景色
 */

@Component
export struct MainPage {
  // 模拟数据列表
  arrayAppInfo: Array<AppInfo> = [];

  aboutToAppear(): void {
    // 添加模拟数据
    this.mockData();
    // 遍历模拟数据，找出每个图标的主颜色，并设置为背景色
    this.arrayAppInfo.forEach(async (item: AppInfo) => {
      // 图片转换为PixelMap对象
      const pixelMap: image.PixelMap = await image2PixelMap(item.icon);
      // 遍历PixelMap中的所有像素，放到一个数组中
      const allPixels: number[] = await traverseAllPixel(pixelMap);
      // 找到数组中出现次数最多的像素
      const maxPixel: number = findMaxPixel(allPixels);
      // 将像素值转换为RGB颜色格式
      let rgb: ColorRgb = ColorUtils.numberToRgb(maxPixel);
      // 将RGB颜色格式转换为HSV格式
      const hsv: ColorHsv = ColorUtils.rgb2hsv(rgb);
      // 如果不是白色像素，修改HSV格式中的S和V值，使背景色和图标颜色有明显区分。如果白色的时候修改S和V的值，可能会导致颜色出现异常
      if (maxPixel !== -1) {
        // 修改HSV格式中的S、V的分量
        modifySVValue(hsv);
      }
      // 将HSV格式转换为RGB格式
      rgb = ColorUtils.hsv2rgb(hsv);
      // 将rgb转换为数字，放入AppInfo对象中
      item.backgroundColor = ColorUtils.rgbToNumber(rgb);
    })
  }

  /**
   * 添加模拟数据
   */
  mockData() {
    const huaweiCloud: AppInfo = new AppInfo('ic_public_game2.png', '云空间', '云存储');
    const huaweiEmail: AppInfo = new AppInfo('ic_public_game3.png', '邮箱', '邮箱管理');
    const huaweiHealth: AppInfo = new AppInfo('ic_public_app3.png', '运动健康', '运动健康管家');
    const huaweiLiving: AppInfo = new AppInfo('ic_public_app4.png', 'WifiLink', '智能家居');
    const huaweiShop: AppInfo = new AppInfo('ic_public_game4.png', '商城', '官方电商平台');
    this.arrayAppInfo.push(huaweiCloud, huaweiEmail, huaweiHealth, huaweiLiving, huaweiShop);
  }

  build() {
    List() {
      ForEach(this.arrayAppInfo, (item: AppInfo) => {
        ListItem() {
          IconItem({ item: item })
        }
      })
    }
    .width($r('app.string.percent_100'))
    .height($r('app.string.percent_100'))
    .padding({
      top: $r('app.integer.column_padding_top')
    })
  }
}

@Component
struct IconItem {
  @ObjectLink item: AppInfo;

  build() {
    Row() {
      Image($rawfile(this.item.icon))
        .margin({
          left: $r('app.integer.image_margin_left')
        })
        .height($r('app.integer.image_size_height'))
        .width($r('app.integer.image_size_width'))
        .borderRadius($r('app.integer.icon_image_border_radius'))
      Column() {
        Text(this.item.name)
          .fontSize($r('app.integer.text_name_font_size'))
          .fontWeight(FontWeight.Bold)
        Text(this.item.description)
          .fontSize($r('app.integer.text_description_font_size'))
          .margin({
            top: $r('app.integer.text_description_margin_top')
          })
      }
      .alignItems(HorizontalAlign.Start)
      .height($r('app.integer.icon_column_height'))
      .margin({
        left: $r('app.integer.icon_column_margin_left')
      })
    }
    .padding({
      left: $r('app.integer.icon_row_padding_left')
    })
    .width($r('app.string.percent_100'))
    .height($r('app.integer.icon_row_height'))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.item.backgroundColor === '' ? Color.White : this.item.backgroundColor)
  }
}

// 应用信息
@Observed
class AppInfo {
  icon: string = '';
  backgroundColor: ResourceColor = '';
  name: string = '';
  description: string = '';

  constructor(icon: string, name: string, description: string) {
    this.icon = icon;
    this.name = name;
    this.description = description;
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getIconMainColor(): void {
  MainPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.ICON_MAIN_COLOR, wrapBuilder(getIconMainColor));