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
import { CardInfo } from '../model/CardModel'

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
  // 卡片偏移量
  @Prop cardOffset: number = 0;
  // 图片预览窗口是否出现的标志位
  @State private isPhotoShow: boolean = false;
  // 当前卡片的序号
  cardIndex: number = 0;
  // Swiper 当前显示的卡片序号
  @Prop showingCard: number = 0;

  build() {
    Column() {
      Row() {
        Image(this.cardInfo.src)
          .objectFit(ImageFit.Cover)
          .borderRadius($r('app.integer.photo_radius'))
          .geometryTransition(this.cardIndex.toString(), { follow: true })
          .transition(TransitionEffect.OPACITY.animation({ duration: Constants.DURATION, curve: Curve.Friction }))
      }
      .width(this.cardInfo.width)
      .height(this.cardInfo.height)
      .margin({ left: this.cardOffset })
      .onClick(() => {
        // 使点击Swiper两侧的图片无效
        if (this.cardIndex != this.showingCard) {
          return;
        }
        // 动画及显示预览窗口
        animateTo({
          duration: Constants.DURATION,
          curve: Curve.Friction
        }, () => {
          this.isPhotoShow = !this.isPhotoShow;
        })
      })
      .bindContentCover(
        this.isPhotoShow,
        this.photoShowBuilder(this.cardInfo.src, this.cardIndex.toString()),
        { backgroundColor: $r('app.color.photo_preview_build_background'), modalTransition: ModalTransition.ALPHA }
      )
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height($r('app.string.full_size'))
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
      animateTo({
        duration: Constants.DURATION,
        curve: Curve.Friction
      }, () => {
        this.isPhotoShow = !this.isPhotoShow;
      })
    })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.opacity(Constants.OPACITY),
      TransitionEffect.OPACITY
    ))
  }
}