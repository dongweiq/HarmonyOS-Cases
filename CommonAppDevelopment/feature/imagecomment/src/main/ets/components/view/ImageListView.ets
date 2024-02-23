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

// 评论中显示图片的组件
@Component
export struct ImageListView {
  // 图片列表
  @Prop selectedImages: ResourceStr[] = [];

  build() {
    List({ space: 10 }) {
      ForEach(this.selectedImages, (image: string, index: number) => {
        ListItem() {
          Image(image)
            .height($r('app.integer.image_comment_image_height'))
            .width($r('app.integer.image_comment_image_width'))
            .onClick(() => {
              // 点击图片时删除图片
              this.selectedImages.splice(index, 1);
            })
            .borderRadius($r('app.integer.image_comment_image_border_radius'))
        }
      })
    }
    .height($r('app.integer.list_comment_image_height'))
    .width($r('app.string.percent_100'))
    .padding({
      top: $r('app.integer.list_comment_image_padding_top'),
      bottom: $r('app.integer.list_comment_image_padding_bottom')
    })
    .listDirection(Axis.Horizontal)
    .alignSelf(ItemAlign.Start)
  }
}