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

import { TabBarDataType } from './DataType';

// TarBar数据
export const TABINFO: TabBarDataType[] = [
  new TabBarDataType(0, $r('app.string.home'), $r("app.media.tabBarMain"), $r('app.media.home')),
  new TabBarDataType(1, $r('app.string.news'), $r('app.media.new_selected'), $r('app.media.new')),
  new TabBarDataType(2, $r('app.string.community'), $r('app.media.community_selected'), $r('app.media.community')),
  new TabBarDataType(3, $r('app.string.shopping_cart'), $r('app.media.cart_selected'), $r('app.media.cart')),
  new TabBarDataType(4, $r('app.string.mine'), $r('app.media.user_selected'), $r('app.media.user')),
];