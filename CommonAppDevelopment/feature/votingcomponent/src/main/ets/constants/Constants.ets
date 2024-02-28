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

export default class Constants {
  static readonly LEFT_COLOR: Color = Color.Red;
  static readonly RIGHT_COLOR: Color = Color.Blue;
  static readonly LEFT_OPTION: string = '早起';
  static readonly RIGHT_OPTION: string = '晚起';
  static readonly BOTTOM_TEXT_SUFFIX: string = '人参与';
  static readonly LEFT_RADIUS: number[][] = [[40, 40], [0, 0], [0, 0], [40, 40]];
  static readonly RIGHT_RADIUS: number[][] = [[0, 0], [40, 40], [40, 40], [0, 0]];
  static readonly BEGIN_POINTS: number[][] = [[20, 0], [90, 0], [80, 80], [10, 80]];
  static readonly END_POINTS: number[][] = [[50, 0], [60, 0], [50, 80], [40, 80]];
  static readonly BEGIN_FILL_OPACITY: number = 1;
  static readonly END_FILL_OPACITY: number = 0.2;
  static readonly PERCENTAGE: number = 100;
  static readonly MID_TEXT_FONT_WEIGHT: number = 900;
  static readonly ANIMATE_DURATION: number = 500;
}