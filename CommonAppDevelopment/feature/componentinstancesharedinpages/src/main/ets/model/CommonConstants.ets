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
  static readonly titleTextMargin: number = 30;
}

export class MapCommonConstants {
  static readonly mapInitOffsetX: number = 20;
  static readonly mapInitOffsetY: number = -950;
  // 地图图片设置为页面3倍，减少拖拽后显示空白
  static readonly mapImageWidth: Length = '300%';
  static readonly mapImageHeight: Length = '300%';
}

export class MainPageCommonConstants {
  static readonly backgroundColor: ResourceColor = '#fff9fcfe';
  static readonly contentAreaRadius: number = 30;
  static readonly mapAreaHeightRatio: number = 0.4;
}

export class TakeTaxiPageCommonConstants {
  static readonly backgroundColor: ResourceColor = '#ffe0eaf4';
  // SHEET页的三段式高度
  static readonly sheetDetents: [Length | SheetSize, (Length | SheetSize)?, (Length | SheetSize)?]
    = ['30%', '50%', '100%'];
}