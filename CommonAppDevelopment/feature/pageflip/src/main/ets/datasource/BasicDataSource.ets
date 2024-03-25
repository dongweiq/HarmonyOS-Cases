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

export class BasicDataSource implements IDataSource {
  private elements: string[] = [];
  private listeners: Set<DataChangeListener>;
  readonly flipPageToastDuration = 300;
  readonly pageFlipTwo = 2;
  readonly pageFlipZero = 0;
  readonly pageFlipOne = 1;
  readonly pageFlipThree = 3;
  readonly pageFlipFive = 5;
  readonly pageFlipEleven = 11;
  readonly pageFlipContentResource = 'app.string.pageflip_content';

  constructor(elements: string[] = []) {
    this.elements = elements;
    this.listeners = new Set();
  }

  public totalCount(): number {
    return this.elements.length;
  }

  public getData(index: number): string {
    // 当index等于this.totalCount() - 1时向后请求网络数据。cacheout等于3,此案例本地只有11条数据，最后几条数据需要另行处理。
    if (index === this.totalCount() - this.pageFlipOne && index < this.pageFlipEleven) {
      for (let i = index + this.pageFlipTwo; i <= index + this.pageFlipFive; i++) {
        this.elements.push(this.pageFlipContentResource + i.toString());
        this.listeners.forEach(listeners => listeners.onDataAdd(this.elements.length - this.pageFlipOne));
      }
    } else if (index === this.pageFlipEleven) {
      for (let i = index + this.pageFlipOne; i <= index + this.pageFlipThree; i++) {
        this.elements.push('app.string.pageflip_content' + i.toString());
        this.listeners.forEach(listeners => listeners.onDataAdd(this.elements.length - this.pageFlipOne));
      }
    }
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
    this.elements.splice(index, this.pageFlipOne);
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataReloaded());
  }

  // 从开头添加数据
  public addItem(item: string): void {
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(this.pageFlipZero));
  }

  // 从结尾插入数据
  public pushItem(item: string): void {
    this.elements.push(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(this.elements.length - this.pageFlipOne));
  }

  public insertItem(item: string, index: number): void {
    this.elements.splice(index, this.pageFlipZero, item);
    this.listeners.forEach(listeners => listeners.onDataAdd(index));
  }

  public deleteItem(item: string): void {
    const index = this.elements.indexOf(item);
    if (index < this.pageFlipZero) {
      return;
    }
    this.elements.splice(index, this.pageFlipOne);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }

  public deleteItemByIndex(index: number): void {
    this.elements.splice(index, this.pageFlipOne);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }
}
