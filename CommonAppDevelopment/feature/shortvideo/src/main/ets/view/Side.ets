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

// 展示视频播放界面右侧用户头像、视频评论数量、收藏数量、分享数量、作者是否被用户关注等信息
@Component
export struct Side {
  @State head: Resource = $r('app.media.app_icon'); // 头像
  @State likeCount: string = ''; // 点赞数量
  @State commentCount: string = ''; // 评论数量
  @State favoriteCount: string = ''; // 收藏数量
  @State shareCount: string = ''; // 分享数量
  @State isFocus: boolean = true; // 是否关注
  @State isLike: boolean = false; // 是否点赞
  @State isFavorite: boolean = true; // 是否收藏
  @State index: number = 0; // 用户下标

  // 点击点赞按钮的回调函数
  private changeLikeCount(isAdd: boolean) {
    let likeCountNum = Number(this.likeCount);
    if(isAdd) {
      likeCountNum++;
    } else {
      likeCountNum--;
    }
    this.likeCount = '' + likeCountNum;
    animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.isLike = !this.isLike;
    })
  }

  // 点击收藏按钮的回调函数
  private changefavoriteCount(isIncrease: boolean) {
    let favoriteCountNum = Number(this.favoriteCount);
    if(isIncrease) {
      favoriteCountNum++;
    } else {
      favoriteCountNum--;
    }
    this.favoriteCount = '' + favoriteCountNum;
    animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.isFavorite = !this.isFavorite;
    })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.head)
          .width($r('app.integer.avatar_size'))
          .height($r('app.integer.avatar_size'))
          .borderRadius($r('app.float.avatar_borderRadius'))
          .border({
            width: 1,
            color: Color.White
          })
        if (this.isFocus) {
          Image($r('app.media.img'))
            .width($r('app.integer.concern_size'))
            .height($r('app.integer.concern_size'))
            .borderRadius($r('app.integer.concern_border_radius'))
            .margin({ bottom: $r('app.integer.concern_margin_bottom') })
            .onClick(() => {
              animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
                this.isFocus = !this.isFocus;
              })
            })
        }
        if (!this.isFocus) {
          Image($r('app.media.follow1'))
            .width($r('app.integer.concern_size'))
            .height($r('app.integer.concern_size'))
            .borderRadius($r('app.integer.concern_border_radius'))
            .margin({ bottom: $r('app.integer.concern_margin_bottom') })
            .onClick(() => {
              animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
                this.isFocus = !this.isFocus;
              })
            })
        }
      }
      .width('100%')
      .height($r('app.integer.avatar_height'))
      .padding({ bottom: $r('app.integer.avatar_padding_bottom') })

      Column() {
        if (!this.isLike) {
          Image($r('app.media.fabulous'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.changeLikeCount(true);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.likeCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
        if (this.isLike) {
          Image($r('app.media.fabulo'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.changeLikeCount(false);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.likeCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
      }.width('60%')
      .height($r('app.integer.all_fabulous_height'))

      Column() {
        Image($r('app.media.new_icon'))
          .height($r('app.integer.fabulous_height'))
          .width($r('app.integer.fabulous_width'))
          .objectFit(ImageFit.ScaleDown)
          .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
        Text(this.commentCount)
          .fontSize($r('app.integer.fabulous_font_size'))
          .fontColor(Color.White)
          .opacity($r('app.float.fabulous_opacity'))
      }.width('60%')
      .height($r('app.integer.all_fabulous_height'))

      Column() {
        if (this.isFavorite) {
          Image($r('app.media.ic_public_highlightsed_white'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .onClick(() => {
              this.changefavoriteCount(true);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.favoriteCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
        if (!this.isFavorite) {
          Image($r('app.media.ic_public_highlightsed_yellow'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .onClick(() => {
              this.changefavoriteCount(false);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.favoriteCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
      }.width('60%')
      .height(60)

      Column() {
        Image($r('app.media.share1'))
          .height($r('app.integer.share_height'))
          .width($r('app.integer.share_height'))
          .objectFit(ImageFit.ScaleDown)
        Text($r('app.string.share'))
          .fontSize($r('app.integer.fabulous_font_size'))
          .fontColor(Color.White)
          .opacity($r('app.float.fabulous_opacity'))
      }.width('60%')
      .height($r('app.integer.share_all_width'))
    }
    .margin({ bottom: $r('app.integer.side_margin_bottom') })
    .height('60%')
    .width($r('app.integer.side_width'))
    .justifyContent(FlexAlign.End)
  }
}

// 展示视频相关信息，比如视频作者的昵称、视频文案、搭配的音乐以及发布时间
@Component
export struct VideoDes {
  @State name: string = ''; // 昵称
  @State description: string = ''; // 文案
  @State hotspot: string = ''; // 上升热点
  @State time: string = ''; // 发布时间

  build() {
    Column() {
      Text(this.name)
        .fontSize($r('app.integer.name_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: $r('app.integer.name_margin_bottom') })

      Text(this.description)
        .fontSize($r('app.integer.new_font_size'))
        .fontColor(Color.White)
        .width('70%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.time)
          .fontSize($r('app.integer.time_font_size'))
          .fontColor($r('app.color.time_color'))
      }
    }
    .padding({ left: $r('app.integer.name_padding_left') })
    .alignItems(HorizontalAlign.Start)
    .width('80%')
  }
}
