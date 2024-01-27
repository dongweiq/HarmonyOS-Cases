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

export class DynamicsImportConstants {
  // 商品图片宽高比
  static readonly PRODUCT_IMAGE_ASPECT_RATIO: number = 1;
  // 商品列表Item的组件id，后面添加商品id区分不同的商品。
  static readonly PRODUCT_VIEW_ID: string = 'goods';
  // 商品列表行间距。
  static readonly PRODUCT_GRID_ROWS_GAP: number = 10;
  // 商品列表列间距。
  static readonly PRODUCT_GRID_COLUMNS_GAP: number = 10;
  // 商品价格字符偏移量，用于和特殊字符对齐。
  static readonly PRODUCT_PRICE_OFFSET: number = -3;
  // 自动分配商品Grid的剩余空间。
  static readonly PRODUCT_GRID_LAYOUT_WEIGHT: number = 1;
  // toast显示时长。
  static readonly TOAST_DURATION: number = 2000;
  static readonly DYNAMICS_IMPORT_LOGGER_SUCCESS: string = '动态加载Logger模块打印日志';
}