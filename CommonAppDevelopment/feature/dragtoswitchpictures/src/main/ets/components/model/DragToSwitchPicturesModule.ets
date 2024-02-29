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
 * 滑块视图类
 */
export class SwiperModule {
  imageSrc: Resource;

  constructor(imageSrc: Resource) {
    this.imageSrc = imageSrc;
  }
}

/**
 * tabBar类
 */
export class TabDataModel {
  // tabId用户切换tabContent
  id: number = 0;
  // tab类别
  navData: string | Resource = '';

  constructor(id: number, navData: string | Resource) {
    this.navData = navData;
    this.id = id;
  }
}

/**
 *  瀑布流列表信息
 */
export class WaterFlowModule {
  // 列表图片
  imageSrc: ResourceStr;
  // 列表介绍
  name: string;
  // 面积
  area: string;

  constructor(imageSrc: ResourceStr, name: string, area: string) {
    this.imageSrc = imageSrc;
    this.name = name;
    this.area = area;
  }
}