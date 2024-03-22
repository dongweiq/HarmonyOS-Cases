/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { EntryOhos } from '@ohos/mpchart';

// 图表的Marker(标志气泡)组件
export class CustomUiInfo {
  type: string;
  width: number;
  height: number;
  showUi: boolean;
  x: number;
  y: number;
  offsetLeft: number;
  offsetRight: number;
  data: EntryOhos | null;
  isInbounds: boolean;

  constructor(
    type: string,
    width: number,
    height: number,
    showUi: boolean = false,
    x: number = 0,
    y: number = 0,
    offsetLeft: number = 0,
    offsetRight: number = 0,
    data: EntryOhos | null = null,
    isInbounds: boolean = false
  ) {
    this.type = type;
    this.x = x;
    this.y = y;
    this.offsetLeft = offsetLeft;
    this.offsetRight = offsetRight;
    this.data = data;
    this.isInbounds = isInbounds;
    this.width = width;
    this.height = height;
    this.showUi = showUi;
  }

  // 设置X轴数据的格式转换器
  getFormattedValue(): string {
    const result = (this.data?.getX() || 1) >= 24 ? '次日' + ((this.data?.getX() || 1) - 24) + '点' : (this.data?.getX() || 1) + '' + '点';
    return result;
  }
}