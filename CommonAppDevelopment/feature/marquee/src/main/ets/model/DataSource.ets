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

import { TRIP_DATA } from './MockData';
import { TripDataType } from './DataType';

// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  // 数据变化监听器
  private listeners: DataChangeListener[] = [];
  // 需要进行数据迭代的数据源
  private originDataArray: TripDataType[] = [];

  // 获取数据的长度
  public totalCount(): number {
    return 0;
  }

  // 获取指定数据项
  public getData(index: number): TripDataType {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

export class TripDataSource extends BasicDataSource {
  // 懒加载数据
  private tripData: Array<TripDataType> = TRIP_DATA;

  totalCount(): number {
    return this.tripData.length;
  }

  // 获取指定数据项
  getData(index: number): TripDataType {
    return this.tripData[index];
  }

  // 存储数据到懒加载数据源中
  pushData(data: TripDataType): void {
    this.tripData.push(data);
    // 在数组头部添加数据
    this.notifyDataAdd(this.tripData.length - 1);
  }
}