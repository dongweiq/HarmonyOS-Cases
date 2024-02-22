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
  static readonly COLOR_HEALTHY: string = '#00CC00';
  static readonly COLOR_NORMAL: string = '#7EBEDE';
  static readonly COLOR_WARN: string = '#FF0000';
  static readonly COLOR_TRANSPARENT: string = '#00000000';
  static readonly PERCENTAGE_STR: string = '%';
  static readonly PROGRESS_STEP: number = 0.5;
  static readonly DIAMETER: number = 200;
  static readonly RADIUS_IN_PX: number = vp2px(Constants.DIAMETER / 2.0);
  static readonly BIG_DIAMETER: number = 220;
  static readonly FULL_PROGRESS: number = 100;
  static readonly ZERO_PROGRESS: number = 0;
  static readonly HEALTHY_PROGRESS: number = 80;
  static readonly WARN_PROGRESS: number = 20;
  static readonly UNIT_ONE: number = 1;
  static readonly PERCENT_RATE: number = 100.0;
  static readonly PROGRESS_CHANGE_INTERVAL: number = 100;
  static readonly ZERO: number = 0;
}