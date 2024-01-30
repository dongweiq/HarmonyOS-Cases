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

// TODO: 知识点：使用@Observed装饰器，为了做到类的嵌套也可以被观察到属性的变化
@Observed
/**
 * 表示商品详细数据的类型，是嵌套类的第三层
 * @class
 */
export class ThirdGoodsItem {
  imgSrc: Resource; // 商品图片
  price: string; // 商品价格

  constructor(imgSrc: Resource, price: string) {
    this.imgSrc = imgSrc;
    this.price = price;
  }
}

// TODO: 知识点：使用@Observed装饰器，为了做到类的嵌套也可以被观察到属性的变化
@Observed
/**
 * 表示商品列表的类型，是嵌套类的第二层
 * @class
 */
export class SecondGoodsItemList {
  itemList: Array<ThirdGoodsItem>;

  constructor(imgSrc: Array<ThirdGoodsItem>) {
    this.itemList = imgSrc;
  }
}

/**
 * 表示商品模型的类型，是嵌套类的首层
 * @class
 */
export class FistGoodsModel {
  itemList: SecondGoodsItemList;

  constructor(itemList: SecondGoodsItemList) {
    this.itemList = itemList;
  }
}

/**
 * 需要更新的商品数据
 */
export let targetItemList: ThirdGoodsItem[] = [
  new ThirdGoodsItem($r('app.media.strawberry'), '价格5'),
  new ThirdGoodsItem($r('app.media.banana'), '价格6'),
  new ThirdGoodsItem($r('app.media.apple'), '价格7'),
  new ThirdGoodsItem($r('app.media.mango'), '价格8')
]

/**
 * 初始商品数据
 */
export let originItemList: ThirdGoodsItem[] = [
  new ThirdGoodsItem($r('app.media.grape'), '价格1'),
  new ThirdGoodsItem($r('app.media.kiwifruit'), '价格2'),
  new ThirdGoodsItem($r('app.media.persimmon'), '价格3'),
  new ThirdGoodsItem($r('app.media.watermelon'), '价格4')
]

/**
 * 初始化商品信息
 */
export function loadSource(): Array<ThirdGoodsItem> {
  let itemDataArray: Array<ThirdGoodsItem> = [];
  for (let index = 0; index < originItemList.length; index++) {
    let item = originItemList[index];
    itemDataArray.push(new ThirdGoodsItem(item.imgSrc, item.price));
  }
  return itemDataArray;
}