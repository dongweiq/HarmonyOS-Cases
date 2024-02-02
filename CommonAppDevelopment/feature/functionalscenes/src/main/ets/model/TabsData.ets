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
 * 首页tabBar信息
 */
export class TabDataModel {
  // tabId用户切换tabContent
  id: number = 0;
  // tab类别
  navData: string | undefined = undefined;

  constructor(id: number, navData: string) {
    this.navData = navData;
    this.id = id;
  }
}


export const TAB_DATA: Array<TabDataModel> = [
  new TabDataModel(0, '全部'),
  new TabDataModel(1, 'UI布局'),
  new TabDataModel(2, '动效'),
  new TabDataModel(3, '三方库'),
  new TabDataModel(4, 'Native'),
  new TabDataModel(5, '其他'),
]

// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: TabDataModel[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): TabDataModel {
    return this.originDataArray[index];
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  /**
   * 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
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

/**
 * 实现TabDataSource接口的对象，用于tabs加载数据
 */
export class TabDataSource extends BasicDataSource {
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