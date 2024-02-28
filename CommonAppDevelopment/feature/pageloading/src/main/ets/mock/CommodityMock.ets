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

import { CommodityDataModel } from '../model/CommodityDataModel';

/**
 * 商品列表数据源
 */
export const PRODUCTS_DATA: Array<CommodityDataModel> = [
  new CommodityDataModel(0, $r("app.media.commodity00"), $r("app.string.commodity_title00"), $r("app.string.commodity_price00"), $r("app.string.commodity_view00"), $r("app.string.commodity_insurance00")),
  new CommodityDataModel(1, $r("app.media.commodity01"), $r("app.string.commodity_title01"), $r("app.string.commodity_price01"), $r("app.string.commodity_view01"), $r("app.string.commodity_insurance01")),
  new CommodityDataModel(2, $r("app.media.commodity02"), $r("app.string.commodity_title02"), $r("app.string.commodity_price02"), $r("app.string.commodity_view02"), $r("app.string.commodity_insurance02")),
  new CommodityDataModel(3, $r("app.media.commodity03"), $r("app.string.commodity_title03"), $r("app.string.commodity_price03"), $r("app.string.commodity_view03"), $r("app.string.commodity_insurance03")),
  new CommodityDataModel(4, $r("app.media.commodity04"), $r("app.string.commodity_title04"), $r("app.string.commodity_price04"), $r("app.string.commodity_view04"), $r("app.string.commodity_insurance04")),
  new CommodityDataModel(5, $r("app.media.commodity05"), $r("app.string.commodity_title05"), $r("app.string.commodity_price05"), $r("app.string.commodity_view05"), $r("app.string.commodity_insurance05"))
];