/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import taskpool from '@ohos.taskpool';


/**
 * IDataSource处理数据监听的基本实现
 */
abstract class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []

  public abstract totalCount(): number

  public getData(index: number): T | void {
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataMove(from, to);
    })
  }
}

// task任务池
async function getFriendMomentByTaskPool(jsonUrl: string): Promise<void> {
  // 初始化Task对象，传入待执行的方法和参数
  let task: taskpool.Task = new taskpool.Task(getWebData, jsonUrl);
  // 向任务池中添加新对象
  let friendMomentArray: Array<FriendMoment> = await taskpool.execute(task, taskpool.Priority.MEDIUM) as Array<FriendMoment>;
  let momentData: FriendMomentsData | undefined = AppStorage.get<FriendMomentsData>('momentData');
  if (momentData !== undefined) {
    // 将数组循环写入页面对象中
    for (let i = 0; i < friendMomentArray.length; i++) {
      momentData.pushData(friendMomentArray[i]);
    }
    AppStorage.setOrCreate('momentData', momentData);
  }
}

class FriendMomentsData extends BasicDataSource<FriendMoment> {
  momentList: Array<FriendMoment> = []
  getJsonIndex: number = 1

  // 获取数据列表长度
  public totalCount(): number {
    return this.momentList.length;
  }

  // 根据index获取具体项
  public getData(index: number): FriendMoment {
    // 判断组件是否已经缓存到最后一项数据了
    if (index == this.momentList.length - 1) {
      // 目前json文件只有3个，所以对3取余后加一实现循环获取3个json
      getFriendMomentByTaskPool(FriendMomentJsonUrl.FRIEND_MOMENT_JSON_URL[this.getJsonIndex % 3]);
      this.getJsonIndex++;
    }
    return this.momentList[index];
  }

  // 向规定位置添加数据
  public addData(index: number, data: FriendMoment): void {
    this.momentList.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  // 向列表追加数据
  public pushData(data: FriendMoment): void {
    this.momentList.push(data);
    this.notifyDataAdd(this.momentList.length - 1);
  }
}

class ChatContact {
  userId: string
  userName: string | Resource
  userImage: string | Resource

  toString(): string {
    return this.userId + '  ' + this.userName + '  ' + this.userImage;
  }

  constructor(id: string, name: string | Resource, image?: string | Resource) {
    this.userId = id;
    this.userName = name;
    this.userImage = $r("app.media.profile_photo");
    if (image != null) {
      this.userImage = image;
    }
  }
}

class FriendMoment {
  id: string
  user: ChatContact
  text: string
  time: string = ''
  imageList: Array<string> = new Array<string>()
  media: string = '' // media为需要获取的视频url
  mediaPreview: string = '' //mediaPreview为需要获取的视频预览图url

  constructor(id: string, user: ChatContact, text: string, time?: string, list?: Array<string>, media?: string, mediaPreview?: string) {
    this.id = id;
    this.user = user;
    if (time !== undefined) {
      this.time = time;
    }
    this.text = text;
    if (list !== undefined && list.length) {
      this.imageList = list;
    }
    else if (media) {
      this.media = media;
      if (mediaPreview !== undefined) {
        this.mediaPreview = mediaPreview;
      }
    }
  }

  toString(): string {
    return this.id + '  ' + this.user.toString() + '  ' + this.text + '  ' + this.time;
  }
}

export {FriendMoment, ChatContact, FriendMomentsData, BasicDataSource}