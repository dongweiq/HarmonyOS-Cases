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
 * 实现WaterFlowDataSource接口的对象，用于瀑布流组件加载数据
 */
export class WaterFlowDataSource extends BasicDataSource<WaterFlowModule> {
  private dataArray: WaterFlowModule[] = [];

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): WaterFlowModule {
    return this.dataArray[index];
  }

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.dataArray.length;
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