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

import { SwiperModule, TabDataModel, WaterFlowModule } from '../model/DragToSwitchPicturesModule';
import { BasicDataSource } from './BasicDataSource';

/**
 * 实现SwiperDataSource接口的对象，用于Swiper加载数据
 */
export class SwiperDataSource extends BasicDataSource<SwiperModule> {
  private dataArray: SwiperModule[] = [];

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): SwiperModule {
    return this.dataArray[index];
  }

  /**
   * 在指定索引位置增加一个元素
   * @param index
   */
  public addData(index: number, data: SwiperModule): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  /**
   * 在数据尾部增加一个元素
   */
  public pushData(data: SwiperModule): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}

/**
 * 实现TabDataSource接口的对象，用于tabs加载数据
 */
export class TabDataSource extends BasicDataSource<TabDataModel> {
  private dataArray: TabDataModel[] = [];

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): TabDataModel {
    return this.dataArray[index];
  }

  /**
   * 在指定索引位置增加一个元素
   * @param index
   */
  public addData(index: number, data: TabDataModel): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  /**
   * 在数据尾部增加一个元素
   */
  public pushData(data: TabDataModel): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}

/**
 * 实现IDataSource接口的对象，用于瀑布流组件加载数据
 */
export class WaterFlowDataSource implements IDataSource {
  private dataArray: WaterFlowModule[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(dataArray: WaterFlowModule[]) {
    for (let i = 0; i < dataArray.length; i++) {
      this.dataArray.push(dataArray[i]);
    }
  }

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): WaterFlowModule {
    return this.dataArray[index];
  }

  /**
   * 通知控制器数据重新加载
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知控制器数据增加
   * @param index 数组索引
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知控制器数据变化
   * @param index 数组索引
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知控制器数据删除
   * @param index 数组索引
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  /**
   * 通知控制器数据位置变化
   * @param from 起始位置
   * @param to 最终位置
   */
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * 注册改变数据的控制器
   * @param listener 数据控制器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销改变数据的控制器
   * @param listener 数据控制器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 增加数据
   */
  public add1stItem(): void {
    this.dataArray.splice(0, 0, this.dataArray[this.dataArray.length]);
    this.notifyDataAdd(0);
  }

  /**
   * 在数据尾部增加一个元素
   */
  public addLastItem(): void {
    this.dataArray.splice(this.dataArray.length, 0, this.dataArray[this.dataArray.length]);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  /**
   * 在指定索引位置增加一个元素
   * @param index
   */
  public addItem(index: number): void {
    this.dataArray.splice(index, 0, this.dataArray[this.dataArray.length]);
    this.notifyDataAdd(index);
  }

  /**
   * 删除第一个元素
   */
  public delete1stItem(): void {
    this.dataArray.splice(0, 1);
    this.notifyDataDelete(0);
  }

  /**
   * 删除第二个元素
   */
  public delete2ndItem(): void {
    this.dataArray.splice(1, 1);
    this.notifyDataDelete(1);
  }

  /**
   * 删除最后一个元素
   */
  public deleteLastItem(): void {
    this.dataArray.splice(-1, 1);
    this.notifyDataDelete(this.dataArray.length);
  }

  /**
   * 重新加载数据
   */
  public reload(): void {
    this.notifyDataReload();
  }

  /**
   * 改变数组数据
   * @param data：新数组
   */
  public modifyAllData(data: WaterFlowModule[]): void {
    this.dataArray = data;
    this.notifyDataReload();
  }
}