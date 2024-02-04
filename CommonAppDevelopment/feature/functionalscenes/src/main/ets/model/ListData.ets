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
 *  首页瀑布流列表信息
 */
export class ListData {
  // 首页列表图片
  imageSrc: ResourceStr;
  // 首页列表名称
  name: string;
  // 首页路由跳转信息
  path: string;
  // 路由的注册名，在路由表中注册动态加载模块时使用
  routerName: string;
  // 路由传参数据
  param: string;
  // 难度星级
  ratingNumber: number;
  // 判断ImageFit模式图片是否需要裁剪
  isCropping: boolean;
  // 图片高度
  imageHeight: number | string;
  // 分类
  category: string;

  constructor(imageSrc: ResourceStr, name: string, routerName: string, ratingNumber: number, isCropping: boolean, imageHeight: number | string, path: string, category: string, param?: string) {
    this.imageSrc = imageSrc;
    this.name = name;
    this.routerName = routerName;
    this.param = param === undefined ? '' : param;
    this.imageHeight = imageHeight;
    this.ratingNumber = ratingNumber;
    this.isCropping = isCropping;
    this.path = path;
    this.category = category;
  }
}