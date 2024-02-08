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

import { Comment } from '../model/CommentModel';
import { ImageListView } from './ImageListView';

// 单个评论组件，用于显示评论
@Component
export struct CommentView {
  // 评论
  private comment: Comment = new Comment('', '', '', [], '');

  build() {
    Column() {
      Row() {
        Image(this.comment.avatar)
          .width($r('app.integer.image_avatar_width'))
          .height($r('app.integer.image_avatar_height'))
          .borderRadius($r('app.integer.image_avatar_border_radius'))
        Column() {
          Text(this.comment.name)
          Text(this.comment.time)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          left: $r('app.integer.comment_column_info_margin_left')
        })
      }
      .width($r('app.string.percent_100'))

      Text(this.comment.comment)
        .width($r('app.string.percent_100'))
        .margin({
          top: $r('app.integer.text_comment_margin_top')
        })
      // 如果评论中有图片，则显示List组件
      if (this.comment.images.length > 0) {
        ImageListView({ selectedImages: this.comment.images })
          .margin({
            top: $r('app.integer.list_comment_image_margin_top')
          })
      }
    }
    .width($r('app.string.percent_100'))
    .padding($r('app.integer.view_comment_padding'))
  }
}
