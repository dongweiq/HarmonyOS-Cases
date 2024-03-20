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

/**
 * 保存卡片信息列表的懒加载类。
 */
export class CardsSource implements IDataSource {
  private list: CardInfo[] = [];

  constructor(list: CardInfo[]) {
    this.list = list;
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): CardInfo {
    return this.list[index];
  }

  registerDataChangeListener(): void {}

  unregisterDataChangeListener(): void {}
}

/**
 * 卡片信息的接口类型。
 */
export interface CardInfo {
  src: Resource,
  width: number,
  height: number
}