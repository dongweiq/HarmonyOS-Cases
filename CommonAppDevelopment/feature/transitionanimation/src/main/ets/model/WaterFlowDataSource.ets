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
  private dataArray: Array<CardData>= []
  private listeners: DataChangeListener[] = []

  constructor() {
    this.dataArray = [
      new CardData(1, $r('app.media.image1'),'云海日出星空！杭州高山露营天花板！很小众','#小众旅行地 位于杭州桐庐的高山露营天花板，海拔700多米，云海概率高，光污染小，能观满天繁星，能赏绝美日出。营地幽静，山上鸟很多，可以看到老鹰在天上翱翔。营地位于山顶，无遮挡，视野很开阔，拍照出片，路面平整，轿车直达。#杭州露营 #杭州周末去哪儿 #杭州周边露营', '开野', $r('app.media.avator1')),
      new CardData(2, $r('app.media.image2'),'穿过人山人海，看山河大海','没有计划，直接出发～我们要热爱生活呀虽然中途开错了高速又碰到了堵车封路，但是穿过人山人海之后，就能到达我们想去的地方，看沿途的风景～我想旅行的意义就是和家人一起去没有去过的地方感受不同的春夏秋冬 #自驾游 #旅行 #平潭岛 #在平凡日子里热爱生活 #帕拉梅拉猎装版', '顺子', $r('app.media.avator2')),
      new CardData(3, $r('app.media.image3'),'终于有人把一些地方旅游攻略整明白了','#旅行社 #穷游攻略 #大学生旅游 #人文景点分享 #旅游攻略 #旅行推荐官 #旅游推荐 #旅游 #我的旅行日记 #境外游', '壹宅壹院', $r('app.media.avator3')),
      new CardData(4, $r('app.media.image4'),'走进现实版塞尔达！！','走进现实版塞尔达！！有人说像光遇岛龙石岛我觉的像现实版塞尔达场景山海绝涯如梦幻般的岛屿·位置：福建省霞浦县四礵列岛交通：轮船或快艇·其中东礵岛和鸟岛真的美草坪海鸟与悬崖峭壁岛上还有悠闲的羊儿·#福建旅游 #城市周边游 #赛尔达#本地人去哪玩  #光遇#小众旅行地 #治愈系风景', 'tzu-hsiao', $r('app.media.avator4')),
      new CardData(5, $r('app.media.image5'),'经常有人问西湖为什么没有栏杆','#西湖 #景区', '冰汤葫芦', $r('app.media.avator5')),
      new CardData(6, $r('app.media.image6'),'以为外滩很美了...直到','来了这些地方... \n1️⃣浦东南路\n2️⃣天水恋\n3️⃣虹口足球场\n4️⃣共青\n5️⃣汭rui\n6️⃣高空咖啡厅', '阳崽', $r('app.media.avator6'))
    ]

  }

  // 获取索引对应的数据
  public getData(index: number): CardData {
    return this.dataArray[index]
  }

  // 通知控制器数据重新加载
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  // 通知控制器数据增加
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  // 通知控制器数据变化
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // 通知控制器数据删除
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  // 通知控制器数据位置变化
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  // 获取数据总数
  public totalCount(): number {
    return this.dataArray.length
  }

  // 注册改变数据的控制器
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // 注销改变数据的控制器
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  // 增加数据
  public add1stItem(item: CardData): void {
    this.dataArray.splice(0, 0, item)
    this.notifyDataAdd(0)
  }

  // 在数据尾部增加一个元素
  public addLastItem(item: CardData): void {
    this.dataArray.splice(this.dataArray.length, 0, item)
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  // 在指定索引位置增加一个元素
  public addItem(index: number, item: CardData): void {
    this.dataArray.splice(index, 0, item)
    this.notifyDataAdd(index)
  }

  // 删除第一个元素
  public delete1stItem(): void {
    this.dataArray.splice(0, 1)
    this.notifyDataDelete(0)
  }

  // 删除第二个元素
  public delete2ndItem(): void {
    this.dataArray.splice(1, 1)
    this.notifyDataDelete(1)
  }

  // 删除最后一个元素
  public deleteLastItem(): void {
    this.dataArray.splice(-1, 1)
    this.notifyDataDelete(this.dataArray.length)
  }

  // 重新加载数据
  public reload(): void {
    this.dataArray.splice(1, 1)
    this.dataArray.splice(3, 2)
    this.notifyDataReload()
  }
}