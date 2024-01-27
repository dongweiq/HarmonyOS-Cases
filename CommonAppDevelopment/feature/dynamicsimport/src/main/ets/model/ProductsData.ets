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

import { Goods } from '../model/GoodsModel';

// 生成本地商品列表数据
export const PRODUCT_DATA: Array<Goods> = [
  new Goods(0, $r('app.media.product001'), $r('app.string.product_data_title_device0'), $r('app.string.product_data_info_device0'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price0')),
  new Goods(1, $r('app.media.product002'), $r('app.string.product_data_title_device1'), $r('app.string.product_data_info_device1'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price1')),
  new Goods(2, $r('app.media.product003'), $r('app.string.product_data_title_device2'), $r('app.string.product_data_info_device2'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price2')),
  new Goods(3, $r('app.media.product004'), $r('app.string.product_data_title_device3'), $r('app.string.product_data_info_device3'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price3')),
  new Goods(4, $r('app.media.product005'), $r('app.string.product_data_title_device4'), $r('app.string.product_data_info_device4'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price4')),
  new Goods(5, $r('app.media.product006'), $r('app.string.product_data_title_device5'), $r('app.string.product_data_info_device5'), $r('app.string.product_data_labels_new_product'), $r('app.string.product_data_price5'))
]
