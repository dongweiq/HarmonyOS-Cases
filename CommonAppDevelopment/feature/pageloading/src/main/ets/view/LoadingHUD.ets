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
 * HUD全称Heads-Up Display（抬头显示）
 */
@Component
export struct LoadingHUD {
  build() {
    Column() {
      // TODO: 知识点：创建加载进展组件，除支持通用属性外，还支持设置加载进度条前景色和设置动画显示或者不显示。
      LoadingProgress()
        .color(Color.White)
        .width($r('app.integer.loading_progress_width')).height($r('app.integer.loading_progress_height'))
      Text($r('app.string.loading_progress_text'))
        .fontSize($r('app.integer.loading_progress_font_size'))
        .fontColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.loading_progress_background'))
    .justifyContent(FlexAlign.Center)
  }
}