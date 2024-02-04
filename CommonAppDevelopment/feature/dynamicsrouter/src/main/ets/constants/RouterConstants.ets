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

// 动态路由中需要加载的模块名
export class RouterNameConstants {
  static readonly ROUTER_NAME_ADDRESS_EXCHANGE: string = 'addressExchange';
  static readonly ROUTER_NAME_BAR_CHAT: string = 'barChartSolution';
  static readonly ROUTER_NAME_CUSTOM_TAB_BAR: string = 'customTabBar';
  static readonly ROUTER_NAME_SECONDARY_LINKAGE: string = 'secondarylinkage';
  static readonly ROUTER_NAME_READ_RAW_FILE: string = 'readRawFile';
  static readonly ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION: string = 'eventTransmissionSolution';
  static readonly ROUTER_NAME_IMAGE_VIEWER: string = 'imageViewer';
  static readonly ROUTER_NAME_PENDING_ITEMS: string = 'pendingitems';
  static readonly ROUTER_NAME_HANDLE_TABS: string = 'handletabs';
  static readonly ROUTER_NAME_LAUNCH_AVERT: string = 'launchAvert';
  static readonly ROUTER_NAME_MODAL_WINDOW: string = 'modalWindow';
  static readonly ROUTER_NAME_SLIDE_TO_HIDE_AND_DISPLACE: string = 'slideToHideAndDisplace';
  static readonly ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER: string = 'NavigationParameterTransfer';
  static readonly ROUTER_NAME_AKI_USE_PRACTICE: string = 'akiUsePractice';
  static readonly ROUTER_NAME_VARIABLE_WATCH: string = 'variableWatch';
  static readonly ROUTER_NAME_GBK_TRANSCODING: string = 'gbktranscoding';
}

// 动态路由中需要加载的模块路径，和functionalscenes模块的build-profile.json5中dependencies下面配置的模块依赖名相同
export class RouterPathConstants {
  static readonly ROUTER_PATH_ADDRESS_EXCHANGE: string = '@ohos/addressexchange';
  static readonly ROUTER_PATH_BAR_CHAT: string = '@ohos/barchart';
  static readonly ROUTER_PATH_CUSTOM_TAB_BAR: string = '@ohos/custom-tabbar';
  static readonly ROUTER_PATH_SECONDARY_LINKAGE: string = '@ohos/secondarylinkage';
  static readonly ROUTER_PATH_READ_RAW_FILE: string = '@ohos/nativerawfile';
  static readonly ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION: string = '@ohos/event-propagation';
  static readonly ROUTER_PATH_IMAGE_VIEWER: string = '@ohos/imageviewer';
  static readonly ROUTER_PATH_PENDING_ITEMS: string = '@ohos/pendingitems';
  static readonly ROUTER_PATH_HANDLE_TABS: string = '@ohos/handtabs';
  static readonly ROUTER_PATH_LAUNCH_AVERT: string = '@ohos/launchscenes';
  static readonly ROUTER_PATH_MODAL_WINDOW: string = '@ohos/modalwindow';
  static readonly ROUTER_PATH_SLIDE_TO_HIDE_AND_DISPLACE: string = '@ohos/slidetohideanddisplace';
  static readonly ROUTER_PATH_NAVIGATION_PARAMETER_TRANSFER: string = '@ohos/NavigationParameterTransferView';
  static readonly ROUTER_PATH_AKI_USE_PRACTICE: string = '@ohos/akiusepractice';
  static readonly ROUTER_PATH_VARIABLE_WATCH: string = '@ohos/variablewatch';
  static readonly ROUTER_PATH_GBK_TRANSCODING: string = '@ohos/gbktranscoding';
}