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

import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';

@Entry
@Component
export struct FitForDarkModePage {
  @State text: ResourceStr = '';
  @State color: ResourceStr = '';
  // @StorageProp + @Watch 获取并监听当前颜色模式
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = 0;

  // @Watch回调函数，监听颜色模式刷新状态变量
  onColorModeChange(): void {
    if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.color = $r('app.color.black_color');
      this.text = $r('app.string.light_string');
    } else {
      this.color = $r('app.color.white_color');
      this.text = $r('app.string.dark_string');
    }
  }

  // 根据当前颜色模式刷新状态变量
  aboutToAppear() {
    console.log(`onColorModeChange: ${this.currentMode}`);
    if (this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.color = $r('app.color.black_color');
      this.text = $r('app.string.light_string');
    } else {
      this.color = $r('app.color.white_color');
      this.text = $r('app.string.dark_string');
    }
  }

  build() {
    Column({ space: 30 }) {
      Column({ space: 5 }) {
        Text($r('app.string.fixed_color_value'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        // TODO: 知识点：UI组件颜色属性是固定颜色值，深浅模式颜色不变。
        // 直接设置成'#000000'固定色值
        Row()
          .backgroundColor($r('app.color.black_color'))
          .borderColor($r('app.color.row_border_color'))
          .borderWidth(2)
          .height(40)
          .width('80%')

      }.alignItems(HorizontalAlign.Start)

      Column({ space: 5 }) {
        Text($r('app.string.resource_color_value'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        // TODO: 知识点：在resources目录下新增dark/element目录，创建深色模式color.json文件，设置深色模式UI组件颜色。（注意事项:颜色name必须相同）
        // 用资源ID方式设置色值
        Row()
          .backgroundColor($r('app.color.row_bg_color'))
          .borderColor($r('app.color.row_border_color'))
          .borderWidth(2)
          .height(40)
          .width('80%')

      }.alignItems(HorizontalAlign.Start)

      Column({ space: 5 }) {
        Text($r('app.string.system_color_value'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        // TODO: 知识点：UI组件颜色属性是系统中的颜色（即分层参数颜色资源），深浅模式自动切换色值。
        // 用系统提供颜色方式设置色值
        Row()
          .backgroundColor($r('sys.color.ohos_id_color_sub_background_dark'))
          .borderColor($r('app.color.row_border_color'))
          .borderWidth(2)
          .height(40)
          .width('80%')

      }.alignItems(HorizontalAlign.Start)

      Column({ space: 5 }) {
        Text($r('app.string.png_format_image'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        Row() {
          // TODO: 知识点：PNG/WEBG/JEPG格式在resources目录下新增dark/media目录，设置深色模式组件图片。（注意事项:图片name必须相同）
          // PNG格式图片资源ID方式设置
          Image($r('app.media.ic_public_list_add'))
            .height(48).width(48)
        }.height(50).width('80%')

      }.alignItems(HorizontalAlign.Start)

      Column({ space: 5 }) {
        Text($r('app.string.svg_format_image'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        Row() {
          // TODO: 知识点：SVG格式在resources目录下新增dark/element目录，创建深色模式color.json文件，设置深色模式图片fillColor颜色。（注意事项:颜色name必须相同）
          // SVG格式图片fillColor颜色资源ID方式设置
          Image($r('app.media.ic_files_name'))
            .height(48).width(48).fillColor($r('app.color.ic_files_name_fillColor'))
        }.height(50).width('80%')

      }.alignItems(HorizontalAlign.Start)

      Column() {
        Text($r('app.string.listen_mode'))
          .fontColor($r('app.color.title_color'))
          .fontSize(15)
        // TODO: 知识点：在深浅模式下，UI布局或逻辑存在差异，采用AbilityStage.onConfigurationUpdate监听实现
        Text(this.text).fontSize(28).fontColor(this.color)
          .height(50).width('80%')

      }.alignItems(HorizontalAlign.Start)

    }.margin({ top: 30 })
    .width('100%')
    .height('100%')
  }
}

