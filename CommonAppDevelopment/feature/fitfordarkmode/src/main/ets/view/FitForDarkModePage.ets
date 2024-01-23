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
import { GoodsList } from './GoodsList'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import window from '@ohos.window';
import { logger } from '@ohos/base';


@Component
export struct FitForDarkModePage {
  @State banner: ResourceStr = '';
  // @StorageProp + @Watch 获取并监听当前颜色模式
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = 0;

  // @Watch回调函数，监听颜色模式刷新状态变量
  onColorModeChange(): void {
    if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      this.banner = $r("app.media.dark_mode_banner");
    } else {
      this.banner = $r("app.media.light_mode_banner");
    }
  }
  // 在自定义组件生命周期aboutToAppear中，根据当前颜色模式刷新banner状态变量，切换不同的图片。
  aboutToAppear(): void {
    if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      this.banner = $r("app.media.dark_mode_banner");
    } else {
      this.banner = $r("app.media.light_mode_banner");
      // 在当前为浅色模式中，确保界面美观且颜色统一，设置导航栏的背景色。
      setStatusBar(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    }
  }
  // 在自定义组件生命周期aboutToDisappear中，重置导航栏的背景色避免影响其它页面的导航栏为红色。
  aboutToDisappear(): void {
    setStatusBar(this.currentMode)
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Image($r('app.media.logo'))
            .width(32)
            .aspectRatio(1)

          Image($r('app.media.scan'))
            .width(32)
            .aspectRatio(1)
        }
        .width('100%')
        .height(32)

        Row() {
          Image($r('app.media.search'))
            .width(20)
            .aspectRatio(1)
            .margin({ left: 20 })
          // TODO: 知识点1：UI组件颜色属性是固定颜色值，深浅模式颜色不变。
          // 将Text直接设置成'#000000'固定色值
          Text("精品好礼")
            .opacity(0.6)
            .fontColor($r('app.color.black_font_color'))
            .margin({ left: 12 })
        }
        .width('100%')
        .height(40)
        .backgroundColor($r('app.color.search_bg_color'))
        .borderRadius(20)

      }
      .padding({ left: 12, right: 12 })
      // TODO: 知识点2：在resources目录下新增dark/element目录，创建深色模式color.json文件，设置深色模式UI组件颜色。（注意事项:颜色name必须相同）
      // 用资源ID方式设置Column背景色。（浅色模式色值为'#FA5A3C'、深色模式色值为'#000000'）
      .backgroundColor($r('app.color.column_bg_color'))
      .width('100%')
      .height(90)


      Scroll() {
        Column() {
          Column() {
            // TODO: 知识点：在深浅模式下，UI布局或逻辑存在差异，采用AbilityStage.onConfigurationUpdate监听实现
            Image(this.banner)
              .width("100%")
              .height(160)
              .borderRadius(20)

            Text("新品首发")
              .fontColor($r('app.color.white_font_color'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .height(45)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 5 })
          }
          .backgroundColor($r('app.color.column_bg_color'))
          .padding({ left: 12, right: 12 })
          .borderRadius({ bottomLeft: 20, bottomRight: 20 })


          // 产品列表组件
          GoodsList()
        }
      }
      .backgroundColor($r("app.color.list_bg_color"))
      .padding({ bottom: 12 })
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

    }
    .backgroundColor($r('app.color.page_bg_color'))
    .width('100%')
    .height('100%')
  }
}

async function setStatusBar(currentMode: number) {
  // 1.获取应用主窗口。
  let windowClass: window.Window;
  let windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  windowStage.getMainWindow((err, data) => {
    if (err.code) {
      logger.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
      return;
    }
    windowClass = data;
    logger.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

    let color = '';
    // 设置窗口为全屏布局，配合设置导航栏、状态栏的透明度、背景/文字颜色及高亮图标等属性，与主窗口显示保持协调一致。
    if (currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      color = '#000000';
    } else if (currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      color = '#FFFFFF';
    } else {
      color = '#FA5a3C';
    }
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: color  // 状态栏背景颜色
    };

    // TODO: 知识点：调用setWindowSystemBarProperties()设置状态栏及导航栏的颜色
    windowClass.setWindowSystemBarProperties(sysBarProps, (err) => {
      if (err.code) {
        logger.error('Failed to set the system bar properties. Cause: ' + JSON.stringify(err));
        return;
      }
      logger.info('Succeeded in setting the system bar properties.');
    });
  })
}