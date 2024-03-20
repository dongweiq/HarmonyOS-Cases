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

import Constants from '../../utils/Constants';
import { CardInfo } from '../model/CardModel';

/**
 * 卡片组件的实现。
 */
@Component
export default struct CardComponent {
  // 卡片数据，默认初始化
  cardInfo: CardInfo = {
    src: $r('app.media.panda'),
    width: Constants.CARD_UNIT_LENGTH,
    height: Constants.CARD_UNIT_LENGTH
  };
  @State cardWith: number = this.cardInfo.width;
  @State cardHeight: number = this.cardInfo.height;
  // 卡片偏移量
  @Prop cardOffset: number = 0;
  // 图片预览窗口是否出现的标志位
  @State private isPhotoShow: boolean = false;
  // 当前卡片的序号
  cardIndex: number = 0;
  // Swiper 当前显示的卡片序号
  @Prop showingCard: number = 0;

  aboutToAppear(): void {
    this.cardWith = this.cardInfo.width;
    this.cardHeight = this.cardInfo.height;
  }

  build() {
    Row() {
      Image(this.cardInfo.src)
        .width(this.cardWith)
        .height(this.cardHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.integer.photo_radius'))
        .shadow({
          radius: $r('app.integer.card_shadow_radius'),
          type: ShadowType.COLOR,
          color: $r('app.color.card_shadow_color'),
          offsetX: $r('app.integer.card_shadow_offsetx'),
          offsetY: $r('app.integer.card_shadow_offsety')
        })
        // TODO 知识点：geometryTransition通过id参数绑定两个组件转场关系，实现一镜到底动画
        .geometryTransition(this.cardIndex.toString(), { follow: true })
        .transition(TransitionEffect.OPACITY.animation({ duration: Constants.DURATION, curve: Curve.Friction }))
        .margin({ left: this.cardOffset })
        .animation({
          curve: Curve.Friction,
          duration: Constants.DURATION
        })
        .onClick(() => {
          // 使点击Swiper两侧的图片无效
          if (this.cardIndex !== this.showingCard) {
            return;
          }
          // 动画及显示预览窗口
          this.animateFunc();
        })
        .bindContentCover(
          this.isPhotoShow,
          this.photoShowBuilder(this.cardInfo.src, this.cardIndex.toString()),
          { backgroundColor: $r('app.color.photo_preview_build_background'), modalTransition: ModalTransition.ALPHA }
        )
        .onTouch((event) => {
          if (event) {
            if (event.type === TouchType.Down) {
              // 按下略微缩小
              this.cardWith = this.cardInfo.width * 0.9;
              this.cardHeight = this.cardInfo.height * 0.9;
            } else if (event.type === TouchType.Up) {
              // 抬起恢复大小
              this.cardWith = this.cardInfo.width;
              this.cardHeight = this.cardInfo.height;
            }
          }
        })
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder photoShowBuilder(img: Resource, id: string) {
    Column() {
      Image(img)
        .borderRadius($r('app.integer.photo_radius'))
        .geometryTransition(id, { follow: true })
        .width($r('app.string.photo_preview_width'))
        .transition(TransitionEffect.opacity(Constants.OPACITY))
    }
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.animateFunc();
    })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.opacity(Constants.OPACITY),
      TransitionEffect.OPACITY
    ))
  }

  animateFunc() {
    animateTo({
      duration: Constants.DURATION,
      curve: Curve.Friction
    }, () => {
      this.isPhotoShow = !this.isPhotoShow;
    })
  }
}