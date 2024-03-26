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
import { logger } from '@ohos/base/Index';

import { CommodityDataModel } from './CommodityDataModel';

/**
 * Basic implementation of IDataSource to handle data listener
 */
class BasicDataSource <T> implements IDataSource {
  // 数据变化监听器
  private listeners: DataChangeListener[] = [];

  /**
   * 获取数据的长度
   */
  public totalCount(): number {
    return 0;
  }

  /**
   * 获取指定数据项
   */
  public getData(index: number): T | void {
    logger.info('getData, index:' + index);
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      logger.info('add listener');
      this.listeners.push(listener);
    }
  }

  /**
   * 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      logger.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 通知LazyForEach组件需要重载所有子组件
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处添加子组件
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处删除该子组件
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

export class CommodityDataSource extends BasicDataSource<CommodityDataModel> {
  // 懒加载数据
  private CommodityList: Array<CommodityDataModel> = []

  /**
   * 获取懒加载数据源的数据长度
   */
  totalCount(): number {
    return this.CommodityList.length;
  }

  /**
   * 获取指定数据项
   */
  getData(index: number): CommodityDataModel {
    return this.CommodityList[index];
  }

  /**
   * 存储数据到懒加载数据源中
   */
  pushData(data: CommodityDataModel[]): void {
    this.CommodityList.push(...data);
    this.notifyDataAdd(this.CommodityList.length - 1);
  }
}