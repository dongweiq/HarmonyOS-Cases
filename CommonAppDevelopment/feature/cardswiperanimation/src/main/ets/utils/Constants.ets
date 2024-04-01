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

import { CardInfo } from '../components/model/CardModel';

export default class Constants {
  // 卡片的单位长度，便于设置卡片的比例
  public static readonly CARD_UNIT_LENGTH: number = 120;
  // 卡片列表测试用例
  public static readonly CARD_TEST_CASE: CardInfo[] = [
    // 卡片比例 1 x 1
    { src: $r('app.media.panda'), width: this.CARD_UNIT_LENGTH, height: this.CARD_UNIT_LENGTH },
    // 卡片比例 1 x 2
    { src: $r('app.media.kangaroo'), width: this.CARD_UNIT_LENGTH, height: 2 * this.CARD_UNIT_LENGTH },
    // 卡片比例 2 x 1
    { src: $r('app.media.bear'), width: 2 * this.CARD_UNIT_LENGTH, height: this.CARD_UNIT_LENGTH },
    // 卡片比例 2 x 2
    { src: $r('app.media.parrot'), width: 2 * this.CARD_UNIT_LENGTH, height: 2 * this.CARD_UNIT_LENGTH },
  ];
  // Swiper 的偏移量
  public static readonly SWIPER_MARGIN: number = 25;
  // 图片动画透明度值
  public static readonly OPACITY: number = 0.99;
  // 图片动画时长
  public static readonly DURATION: number = 280;
}