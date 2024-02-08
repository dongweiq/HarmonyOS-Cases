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
  static readonly ROUTER_NAME_ADDRESS_EXCHANGE: string = '@ohos/addressexchange';
  static readonly ROUTER_NAME_BAR_CHAT: string = '@ohos/barchart';
  static readonly ROUTER_NAME_CUSTOM_TAB_BAR: string = '@ohos/custom-tabbar';
  static readonly ROUTER_NAME_SECONDARY_LINKAGE: string = '@ohos/secondarylinkage';
  static readonly ROUTER_NAME_READ_RAW_FILE: string = '@ohos/nativerawfile';
  static readonly ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION: string = '@ohos/event-propagation';
  static readonly ROUTER_NAME_IMAGE_VIEWER: string = '@ohos/imageviewer';
  static readonly ROUTER_NAME_PENDING_ITEMS: string = '@ohos/pendingitems';
  static readonly ROUTER_NAME_HANDLE_TABS: string = '@ohos/handtabs';
  static readonly ROUTER_NAME_MODAL_WINDOW: string = '@ohos/modalwindow';
  static readonly ROUTER_NAME_SLIDE_TO_HIDE_AND_DISPLACE: string = '@ohos/slidetohideanddisplace';
  static readonly ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER: string = '@ohos/NavigationParameterTransferView';
  static readonly ROUTER_NAME_AKI_USE_PRACTICE: string = '@ohos/akiusepractice';
  static readonly ROUTER_NAME_VARIABLE_WATCH: string = '@ohos/variablewatch';
  static readonly ROUTER_NAME_GBK_TRANSCODING: string = '@ohos/gbktranscoding';
  static readonly ROUTER_NAME_PHOTO_PICK_AND_SAVE: string = '@ohos/photopickandsave';
  static readonly ROUTER_NAME_FAULT: string = '@ohos/applicationexception';
  static readonly ROUTER_NAME_DARK_MODE: string = '@ohos/fitfordarkmode';
  static readonly ROUTER_NAME_MARQUEE: string = '@ohos/marquee';
  static readonly ROUTER_NAME_PULL_TO_REFRESH: string = '@ohos/pulltorefreshnews';
  static readonly ROUTER_NAME_PAGE_TURNING_ANIMATION: string = '@ohos/pageturninganimation';
  static readonly ROUTER_NAME_VERIFY_CODE: string = '@ohos/verifycode';
  static readonly ROUTER_NAME_NATIVE_PROGRESS_NOTIFY: string = '@ohos/nativeprogressnotify';
  static readonly ROUTER_NAME_VIBRATE_EFFECT: string = '@ohos/vibrateeffect';
  static readonly ROUTER_NAME_SWIPER_SMOOTH_VARIATION: string = '@ohos/swipersmoothvariation';
  static readonly ROUTER_NAME_NAVIGATION_BAR_CHANGE: string = '@ohos/navigationbarchange';
  static readonly ROUTER_NAME_MEDIA_FULL_SCREEN: string = '@ohos/mediafullscreen';
  static readonly ROUTER_NAME_CITY_SEARCH: string = '@ohos/citysearch';
  static readonly ROUTER_NAME_FOLDABLE_SCREEN_CASES: string = '@ohos/foldablescreencases';
}

// 动态路由中需要加载的模块路径，和functionalscenes模块的build-profile.json5中dependencies下面配置的模块依赖名相同
export class RouterPathConstants {
  static readonly ROUTER_PATH_ADDRESS_EXCHANGE: string = './src/main/ets/view/AddressExchangeView';
  static readonly ROUTER_PATH_BAR_CHAT: string = './src/main/ets/view/BarChart';
  static readonly ROUTER_PATH_CUSTOM_TAB_BAR: string = './src/main/ets/view/TabView';
  static readonly ROUTER_PATH_SECONDARY_LINKAGE: string = './src/main/ets/pages/SecondaryLinkExample';
  static readonly ROUTER_PATH_READ_RAW_FILE: string = './src/main/ets/components/mainpage/MainPage';
  static readonly ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION: string = './src/main/ets/view/EventPropagation';
  static readonly ROUTER_PATH_IMAGE_VIEWER: string = './src/main/ets/view/ImageViewerView';
  static readonly ROUTER_PATH_PENDING_ITEMS: string = './src/main/ets/pages/ToDoList';
  static readonly ROUTER_PATH_HANDLE_TABS: string = './src/main/ets/pages/HandleTabs';
  static readonly ROUTER_PATH_MODAL_WINDOW: string = './src/main/ets/ModalWindow';
  static readonly ROUTER_PATH_SLIDE_TO_HIDE_AND_DISPLACE: string = './src/main/ets/SlideToHideAndDisplace';
  static readonly ROUTER_PATH_NAVIGATION_PARAMETER_TRANSFER: string = './src/main/ets/view/NavigationParameterTransferView';
  static readonly ROUTER_PATH_AKI_USE_PRACTICE: string = './src/main/ets/view/AkiView';
  static readonly ROUTER_PATH_VARIABLE_WATCH: string = './src/main/ets/view/VariableWatchView';
  static readonly ROUTER_PATH_GBK_TRANSCODING: string = './src/main/ets/pages/FriendsBook';
  static readonly ROUTER_PATH_PHOTO_PICK_AND_SAVE: string = './src/main/ets/components/PictureManager';
  static readonly ROUTER_PATH_FAULT: string = './src/main/ets/view/ApplicationException';
  static readonly ROUTER_PATH_DARK_MODE: string = './src/main/ets/view/FitForDarkMode';
  static readonly ROUTER_PATH_MARQUEE: string = './src/main/ets/view/Marquee';
  static readonly ROUTER_PATH_PULL_TO_REFRESH: string = './src/main/ets/pages/PullToRefreshNews';
  static readonly ROUTER_PATH_PAGE_TURNING_ANIMATION: string = './src/main/ets/view/PageTurningAnimation';
  static readonly ROUTER_PATH_VERIFY_CODE: string = './src/main/ets/view/VerifyCodeView';
  static readonly ROUTER_PATH_NATIVE_PROGRESS_NOTIFY: string = './src/main/ets/view/NativeProgressNotify';
  static readonly ROUTER_PATH_VIBRATE_EFFECT: string = './src/main/ets/VibrateEffect';
  static readonly ROUTER_PATH_SWIPER_SMOOTH_VARIATION: string = './src/main/ets/pages/MainPage';
  static readonly ROUTER_PATH_NAVIGATION_BAR_CHANGE: string = './src/main/ets/view/NavigationBarChange';
  static readonly ROUTER_PATH_MEDIA_FULL_SCREEN: string = './src/main/ets/view/MediaFullScreen';
  static readonly ROUTER_PATH_CITY_SEARCH: string = './src/main/ets/view/CitySearch';
  static readonly ROUTER_PATH_MUSIC_PLAYER: string = './src/main/ets/pages/MusicPlayerPage';
}