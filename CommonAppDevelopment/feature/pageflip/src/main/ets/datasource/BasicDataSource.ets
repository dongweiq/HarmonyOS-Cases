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
import { CONFIGURATION, STRINGCONFIGURATION } from '../common/Constants';

export class BasicDataSource implements IDataSource {
  private elements: string[] = [];
  private listeners: Set<DataChangeListener>;

  constructor(elements: string[]) {
    this.elements = elements;
    this.listeners = new Set();
  }

  public totalCount(): number {
    return this.elements.length;
  }

  public getData(index: number): string {
    /**
     * TODO:知识点:1.当index等于this.totalCount() - 1时向后请求网络数据。当index等于0时向前请求网络数据。
     * TODO:知识点:2.新请求到的数据可以通过push插入到队尾，通知listeners刷新添加可参考pushItem方法。如果想要插到队头可以通过unshift插入到队头，通知listeners刷新添加可参考addItem方法。
     */
    return this.elements[index];
  }

  public indexOf(item: string): number {
    return this.elements.indexOf(item);
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  public registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  public unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.delete(listener);
  }

  public pinItem(item: string, index: number): void {
    this.elements.splice(index, CONFIGURATION.PAGEFLIPONE);
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataReloaded());
  }

  // 从开头添加数据
  public addItem(item: string): void {
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(CONFIGURATION.PAGEFLIPZERO));
  }

  // 从结尾插入数据
  public pushItem(item: string): void {
    this.elements.push(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(this.elements.length - CONFIGURATION.PAGEFLIPONE));
  }

  public insertItem(item: string, index: number): void {
    this.elements.splice(index, CONFIGURATION.PAGEFLIPZERO, item);
    this.listeners.forEach(listeners => listeners.onDataAdd(index));
  }

  public deleteItem(item: string): void {
    const index = this.elements.indexOf(item);
    if (index < CONFIGURATION.PAGEFLIPZERO) {
      return;
    }
    this.elements.splice(index, CONFIGURATION.PAGEFLIPONE);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }

  public deleteItemByIndex(index: number): void {
    this.elements.splice(index, CONFIGURATION.PAGEFLIPONE);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }
}
