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

import { CardData } from './CardData'

// 实现IDataSource接口的对象，用于瀑布流组件加载数据
export class WaterFlowDataSource implements IDataSource {
  private dataArray: Array<CardData> = [];
  private listeners: DataChangeListener[] = [];

  constructor() {
    this.dataArray = [
      new CardData(1, $r('app.media.image1'), $r('app.string.card_title1'), $r('app.string.card_content1'), $r('app.string.author_name1'), $r('app.media.avator1')),
      new CardData(2, $r('app.media.image2'), $r('app.string.card_title2'), $r('app.string.card_content2'), $r('app.string.author_name2'), $r('app.media.avator2')),
      new CardData(3, $r('app.media.image3'), $r('app.string.card_title3'), $r('app.string.card_content3'), $r('app.string.author_name3'), $r('app.media.avator3')),
      new CardData(4, $r('app.media.image4'), $r('app.string.card_title4'), $r('app.string.card_content4'), $r('app.string.author_name4'), $r('app.media.avator4')),
      new CardData(5, $r('app.media.image5'), $r('app.string.card_title5'), $r('app.string.card_content5'), $r('app.string.author_name5'), $r('app.media.avator5')),
      new CardData(6, $r('app.media.image6'), $r('app.string.card_title6'), $r('app.string.card_content6'), $r('app.string.author_name6'), $r('app.media.avator6'))
    ];
  }

  public getData(index: number): CardData {
    return this.dataArray[index];
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  public add1stItem(item: CardData): void {
    this.dataArray.splice(0, 0, item);
    this.notifyDataAdd(0);
  }

  public addLastItem(item: CardData): void {
    this.dataArray.splice(this.dataArray.length, 0, item);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public addItem(index: number, item: CardData): void {
    this.dataArray.splice(index, 0, item);
    this.notifyDataAdd(index);
  }

  public delete1stItem(): void {
    this.dataArray.splice(0, 1);
    this.notifyDataDelete(0);
  }

  public delete2ndItem(): void {
    this.dataArray.splice(1, 1);
    this.notifyDataDelete(1);
  }

  public deleteLastItem(): void {
    this.dataArray.splice(-1, 1);
    this.notifyDataDelete(this.dataArray.length);
  }

  public reload(): void {
    this.dataArray.splice(1, 1);
    this.dataArray.splice(3, 2);
    this.notifyDataReload();
  }
}