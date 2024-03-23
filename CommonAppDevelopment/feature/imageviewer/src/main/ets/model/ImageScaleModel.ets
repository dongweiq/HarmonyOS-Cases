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

@Observed
export class ImageScaleModel {
  /**
   * scaleValue: 本次缩放因子，用于控制图片的大小显示
   * pinchValue：记录上次缩放完后的缩放因子
   * defaultMaxScaleValue：默认的最大放大值
   * defaultScaleValue：默认缩放值，1
   */
  public scaleValue: number;
  public pinchValue: number;
  public defaultMaxScaleValue: number;
  public readonly defaultScaleValue: number = 1;

  constructor(scaleValue: number, pinchValue: number, defaultMaxScaleValue: number = 3) {
    this.scaleValue = scaleValue;
    this.pinchValue = pinchValue;
    this.defaultMaxScaleValue = defaultMaxScaleValue;
  }

  reset(): void {
    this.scaleValue = this.defaultScaleValue;
    this.pinchValue = this.scaleValue;
  }

  stash(): void {
    this.pinchValue = this.scaleValue;
  }

  toString(): string {
    return `[scaleValue: ${this.scaleValue} pinchValue: ${this.pinchValue}]`;
  }
}