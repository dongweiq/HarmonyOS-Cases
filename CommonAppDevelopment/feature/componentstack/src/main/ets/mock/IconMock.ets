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

import { IconDataModel, ProductDataModel } from '../model/IconModel'

// 快捷图标数据
export const ICON_DATA1: Array<IconDataModel> = [
  new IconDataModel(0, 2, $r('app.media.ic_device_matebook_filled'), '笔记本'),
  new IconDataModel(1, 2, $r('app.media.ic_device_smartscreen_filled'), '智慧屏'),
  new IconDataModel(2, 1, $r('app.media.ic_device_soundx_filled'), '音箱'),
  new IconDataModel(3, 1, $r('app.media.ic_device_vrglass_filled'), 'VR眼镜'),
  new IconDataModel(4, 1, $r('app.media.ic_device_watch_filled'), '手表'),
  new IconDataModel(5, 1, $r('app.media.ic_public_devices_phone_filled'), '手机')
];

// 快捷图标数据
export const ICON_DATA2: Array<IconDataModel> = [
  new IconDataModel(0, 1, $r('app.media.ic_gallery_puzzle'), '拼图'),
  new IconDataModel(1, 1, $r('app.media.ic_public_car'), '汽车'),
  new IconDataModel(2, 1, $r('app.media.ic_public_cards'), '钱包'),
  new IconDataModel(3, 1, $r('app.media.ic_public_highlight'), '收藏'),
  new IconDataModel(4, 1, $r('app.media.ic_contacts_birthday'), '生日'),
];

// 商品列表数据源
export const PRODUCT_DATA: Array<ProductDataModel> = [
  new ProductDataModel(0, $r('app.media.product00'), $r('app.string.product_title00'), $r('app.string.product_price00'), $r('app.string.product_insurance00')),
  new ProductDataModel(1, $r('app.media.product01'), $r('app.string.product_title01'), $r('app.string.product_price01'), $r('app.string.product_insurance01')),
  new ProductDataModel(2, $r('app.media.product02'), $r('app.string.product_title02'), $r('app.string.product_price02'), $r('app.string.product_insurance02')),
  new ProductDataModel(3, $r('app.media.product03'), $r('app.string.product_title03'), $r('app.string.product_price03'), $r('app.string.product_insurance03')),
  new ProductDataModel(4, $r('app.media.product04'), $r('app.string.product_title04'), $r('app.string.product_price04'), $r('app.string.product_insurance04')),
  new ProductDataModel(5, $r('app.media.product05'), $r('app.string.product_title05'), $r('app.string.product_price05'), $r('app.string.product_insurance05'))
];