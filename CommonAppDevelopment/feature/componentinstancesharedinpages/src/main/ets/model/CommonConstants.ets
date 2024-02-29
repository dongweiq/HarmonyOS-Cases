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

export class CommonConstants {
  static readonly CARD_HEIGHT: number = 120;
  static readonly CARD_WIDTH: Length = '90%';
  static readonly CARD_BACKGROUND_COLOR: ResourceColor = '#ffd2d2d2';
  static readonly CARD_BORDER_WIDTH: number = 2;
  static readonly CARD_BORDER_RADIUS: number = 15;
  static readonly CARD_MARGIN: number = 5;
  static readonly CARD_NO_ARRAY: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  static readonly TITLE_FONT_SIZE: number = 20;
  static readonly TITLE_FONT_WEIGHT: number = 800;
  static readonly TITLE_TEXT_MARGIN: number = 20;
}

export class MapCommonConstants {
  static readonly MAP_INIT_OFFSET_X: number = 20;
  static readonly MAP_INIT_OFFSET_Y: number = -950;
  // 地图图片设置为页面3倍，减少拖拽后显示空白
  static readonly MAP_IMAGE_WIDTH: Length = '300%';
  static readonly MAP_IMAGE_HEIGHT: Length = '300%';
}

export class MainPageCommonConstants {
  static readonly CONTENT_AREA_RADIUS: number = 30;
  static readonly MAP_AREA_HEIGHT_RATIO: number = 0.3;
}

export class TakeTaxiPageCommonConstants {
  // SHEET页的三段式高度
  static readonly SHEET_DETENTS: [Length | SheetSize, (Length | SheetSize)?, (Length | SheetSize)?]
    = ['30%', '50%', '100%'];
}