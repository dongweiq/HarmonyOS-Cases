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

import { Comment, CommentData } from '../model/CommentModel';
import { CommentView } from './CommentItemView';
import { CommentInputDialog } from './CommentInputDialog';
import { mockData } from '../model/MockCommentData';
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsrouter/Index';

/** 图片评论页面
 * 实现步骤：
 * 1.添加评论列表
 * 2.点击评论组件，弹出评论输入框，输入文字，点击相机按钮拉起相机拍照，并在列表中显示照片
 * 3.点击发布，将评论添加到列表中
 */

const ID_ROW_PUBLISH: string = "id_row_publish";
const ID_TEXT_EMPTY: string = "id_text_empty";
const ID_LIST: string = "id_list";
const ID_TEXT_TITLE: string = "id_text_title";
const ID_IMAGE: string = "id_image";

@Component
export struct ImageCommentView {
  // 评论列表
  @State commentList: CommentData = new CommentData();
  // 评论中的文字
  @State textInComment: string = "";
  // 评论中的图片列表
  @State imageInComment: string[] = [];
  // 评论数量，用于刷新列表
  @StorageLink('commentCount') commentCount: number = 0;
  // 评论输入弹窗
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CommentInputDialog({
      textInComment: $textInComment,
      imagesInComment: $imageInComment,
      publish: () => this.publishComment()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    offset: { dx: 0, dy: -20 }
  });

  aboutToAppear(): void {
    // 添加模拟数据
    this.commentList = mockData();
    this.commentCount = this.commentList.totalCount();
  }

  aboutToDisappear() {
    // 将dialogController置空
    this.dialogController = null;
  }

  // 发布评论
  publishComment(): void {
    let comment: Comment = new Comment("Kevin", this.textInComment, $r('app.media.icon'), this.imageInComment, this.getCurrentDate());
    this.commentList.pushData(comment);
  }

  // 获取当前时间
  getCurrentDate(): string {
    let date: Date = new Date();
    return `${date.getFullYear()}-${date.getMonth()}-${date.getDay()} ${date.getHours()}:${date.getMinutes()}`;
  }

  build() {
    RelativeContainer() {
      Image($r('app.media.launch_advert'))
        .height($r('app.string.percent_30'))
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_IMAGE)
      Text($r('app.string.hot_comment'))
        .height($r('app.integer.text_hot_comment_height'))
        .width($r('app.string.percent_100'))
        .padding({
          left: $r('app.integer.text_hot_comment_padding_left')
        })
        .border({
          width: {
            bottom: $r('app.integer.text_hot_comment_border_width_bottom')
          },
          color: {
            bottom: $r('app.color.color_divider')
          }
        })
        .alignRules({
          top: { anchor: ID_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_TEXT_TITLE)

      if (this.commentCount > 0) {
        List() {
          // TODO：知识点：使用LazyForEach加载评论列表，可以按需加载，解决一次性加载全部列表数据引起的卡顿问题，提高页面响应速度
          LazyForEach(this.commentList, (comment: Comment) => {
            ListItem() {
              CommentView({ comment: comment })
            }
          })
        }
        .scrollBar(BarState.Off)
        .width($r('app.string.percent_100'))
        .margin({
          bottom: $r('app.integer.list_comment_margin_bottom')
        })
        .alignRules({
          top: { anchor: ID_TEXT_TITLE, align: VerticalAlign.Bottom },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_LIST)
      } else {
        Text($r('app.string.no_comment'))
          .textAlign(TextAlign.Center)
          .width($r('app.string.percent_100'))
          .margin({
            bottom: $r('app.integer.text_no_comment_margin_bottom')
          })
          .alignRules({
            top: { anchor: ID_TEXT_TITLE, align: VerticalAlign.Bottom },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .id(ID_TEXT_EMPTY)
      }

      Row() {
        Text($r('app.string.text_input_hint'))
          .borderRadius($r('app.integer.text_input_hint_border_radius'))
          .height($r('app.integer.text_input_hint_height'))
          .width($r('app.string.percent_95'))
          .padding({
            left: $r('app.integer.text_input_hint_padding_left')
          })
          .backgroundColor($r('app.color.color_comment_text_background'))
          .onClick(() => {
            if (this.dialogController != null) {
              // 打开评论输入弹窗
              this.dialogController.open();
            }
          })
          .border({
            width: $r('app.integer.text_input_hint_border_width'),
            color: $r('app.color.color_comment_text_border')
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height($r('app.integer.row_input_hint_height'))
      .width('100%')
      .border({
        width: {
          top: $r('app.integer.row_input_hint_border_width_top')
        },
        color: {
          top: $r('app.color.color_divider')
        }
      })
      .alignRules({
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      })
      .id(ID_ROW_PUBLISH)

    }
    .width($r('app.string.percent_100'))
    .height($r('app.string.percent_100'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getImageCommentView(): void {
  ImageCommentView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_IMAGE_COMMENT;
if (!DynamicsRouter.getBuilder(builderName)) {
  let builder: WrappedBuilder<[object]> = wrapBuilder(getImageCommentView);
  DynamicsRouter.registerBuilder(builderName, builder);
}