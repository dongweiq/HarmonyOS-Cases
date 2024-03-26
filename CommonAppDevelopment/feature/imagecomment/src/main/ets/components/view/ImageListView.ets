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

const ID_IMAGE: string = 'image';
const ID_DELETE: string = 'delete';

// 评论中显示图片的组件
@Component
export struct ImageListView {
  // 图片列表
  @State selectedImages: ResourceStr[] = [];
  // 是否可以删除列表中的图片
  imageEnableDelete: boolean = false;

  build() {
    List({ space: 10 }) {
      ForEach(this.selectedImages, (image: string, index: number) => {
        ListItem() {
          RelativeContainer() {
            Image(image)
              .height($r('app.integer.image_comment_image_height'))
              .width($r('app.integer.image_comment_image_width'))
              .borderRadius($r('app.integer.image_comment_image_border_radius'))
              .alignRules({
                bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                left: { anchor: "__container__", align: HorizontalAlign.Start }
              })
              .id(ID_IMAGE + index)
            if (this.imageEnableDelete) {
              Image($r('app.media.ic_public_close_filled'))
                .height($r('app.integer.image_delete_height'))
                .width($r('app.integer.image_delete_width'))
                .onClick(() => {
                  if (this.imageEnableDelete) {
                    // 点击图片时删除图片
                    this.selectedImages.splice(index, 1);
                  }
                })
                .alignRules({
                  top: { anchor: "__container__", align: VerticalAlign.Top },
                  right: { anchor: "__container__", align: HorizontalAlign.End }
                })
                .id(ID_DELETE + index)
            }
          }
          .width($r('app.integer.image_relative_container_width'))
          .height($r('app.integer.image_relative_container_height'))
        }
      })
    }
    .height($r('app.integer.list_comment_image_height'))
    .width($r('app.string.percent_100'))
    .padding({
      bottom: $r('app.integer.list_comment_image_padding_bottom')
    })
    .listDirection(Axis.Horizontal)
    .alignSelf(ItemAlign.Start)
  }
}