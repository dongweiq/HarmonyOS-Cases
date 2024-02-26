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

import promptAction from '@ohos.promptAction';
import { cameraCapture } from '../utils/CameraUtils';
import common from '@ohos.app.ability.common';
import { ImageListView } from './ImageListView';

// 选择图片的最大数量
const MAX_SELECT_IMAGE: number = 9;
const ID_TEXT_INPUT: string = "id_text_input";
const ID_IMAGE_CAMERA: string = "id_image_camera";
const ID_TEXT_PUSH: string = "id_text_publish";

/** 输入评论弹窗，用于输入文字和图片评论
 * 实现步骤：
 * 1.添加相机按钮、发布按钮
 * 2.点击按钮时通过startAbilityForResult接口拉起相机
 * 3.拍照后获取相机返回的照片地址，并显示在列表中
 * 4.点击发布按钮，将评论添加到列表中
 */
@CustomDialog
export struct CommentInputDialog {
  // 选择的照片列表
  @State selectedImages: string[] = [];
  // 输入的文字
  @State text: string = "";
  @Link textInComment: string;
  @Link imagesInComment: string[];
  controller?: CustomDialogController;
  // 发布接口，用于主页面更新评论数据
  publish: () => void = (): void => {
  }

  build() {
    Column() {
      RelativeContainer() {
        TextInput()
          .height($r('app.integer.text_input_height'))
          .padding({
            left: $r('app.integer.text_input_padding_left'),
            right: $r('app.integer.text_input_padding_right'),
            top: $r('app.integer.text_input_padding_top'),
            bottom: $r('app.integer.text_input_padding_bottom')
          })
          .margin({
            right: $r('app.integer.text_input_margin_top')
          })
          .onChange((textInComment: string) => {
            this.text = textInComment;
          })
          .defaultFocus(true)
          .alignRules({
            // 性能知识点：使用相对布局组件RelativeContainer，子组件通过alignRules接口将父组件或者其他组件设为锚点，可使布局扁平化，有利于性能提升
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: ID_TEXT_PUSH, align: HorizontalAlign.Start }
          })
          .id(ID_TEXT_INPUT)
        Image($r('app.media.camera'))
          .height($r('app.integer.image_camera_height'))
          .width($r('app.integer.image_camera_width'))
          .onClick(async () => {
            if (this.selectedImages.length >= MAX_SELECT_IMAGE) {
              promptAction.showToast({ message: $r('app.string.most_select_image') });
              return;
            }
            // 拉起相机进行拍照
            let image: string = await cameraCapture(getContext(this) as common.UIAbilityContext);
            if (image !== "") {
              this.selectedImages.push(image);
            }
          })
          .margin({
            right: $r('app.integer.image_camera_margin_top')
          })
          .alignRules({
            top: { anchor: ID_TEXT_INPUT, align: VerticalAlign.Top },
            bottom: { anchor: ID_TEXT_INPUT, align: VerticalAlign.Bottom },
            right: { anchor: ID_TEXT_INPUT, align: HorizontalAlign.End }
          })
          .id(ID_IMAGE_CAMERA)
        Button($r('app.string.publish'))
          .width($r('app.integer.button_publish_width'))
          .height($r('app.integer.button_publish_height'))
          .borderRadius($r('app.integer.button_publish_border_radius'))
          .backgroundColor($r('app.color.button_publish_background'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.controller) {
              this.textInComment = this.text;
              this.imagesInComment = this.selectedImages;
              this.publish();
              this.controller.close();
              this.textInComment = "";
              this.imagesInComment = [];
            }
          })
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .id(ID_TEXT_PUSH)
      }
      .height($r('app.integer.relative_container_input_height'))

      if (this.selectedImages.length > 0) {
        ImageListView({ selectedImages: this.selectedImages })
      }
    }
    .padding($r('app.integer.column_input_padding'))
    .backgroundColor(Color.White)
    .offset({
      y: $r('app.integer.column_input_dialog_offset_y')
    }) // 添加y轴偏移量，否则弹窗和输入法间会有空白
  }
}