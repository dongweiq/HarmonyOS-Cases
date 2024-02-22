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

// 动态路由中需要加载的模块名和模块路径，和functionalscenes模块的build-profile.json5中dependencies下面配置的模块依赖名相同
export class RouterInfo {
  static readonly ADDRESS_EXCHANGE: string[] = ['@ohos/addressexchange', './src/main/ets/view/AddressExchangeView'];
  static readonly BAR_CHAT: string[] = ['@ohos/barchart', './src/main/ets/view/BarChart'];
  static readonly CUSTOM_TAB_BAR: string[] = ['@ohos/custom-tabbar', './src/main/ets/view/TabView'];
  static readonly SECONDARY_LINKAGE: string[] = ['@ohos/secondarylinkage', './src/main/ets/pages/SecondaryLinkExample'];
  static readonly READ_RAW_FILE: string[] = ['@ohos/nativerawfile', './src/main/ets/components/mainpage/MainPage'];
  static readonly EVENT_TRANSMISSION_SOLUTION: string[] = ['@ohos/event-propagation', './src/main/ets/view/EventPropagation'];
  static readonly IMAGE_VIEWER: string[] = ['@ohos/imageviewer', './src/main/ets/view/ImageViewerView'];
  static readonly PENDING_ITEMS: string[] = ['@ohos/pendingitems', './src/main/ets/pages/ToDoList'];
  static readonly HANDLE_TABS: string[] = ['@ohos/handtabs', './src/main/ets/pages/HandleTabs'];
  static readonly MODAL_WINDOW: string[] = ['@ohos/modalwindow', './src/main/ets/ModalWindow'];
  static readonly SLIDE_TO_HIDE_AND_DISPLACE: string[] = ['@ohos/slidetohideanddisplace', './src/main/ets/SlideToHideAndDisplace'];
  static readonly NAVIGATION_PARAMETER_TRANSFER: string[] = ['@ohos/NavigationParameterTransferView', './src/main/ets/view/NavigationParameterTransferView'];
  static readonly AKI_USE_PRACTICE: string[] = ['@ohos/akiusepractice', './src/main/ets/view/AkiView'];
  static readonly VARIABLE_WATCH: string[] = ['@ohos/variablewatch', './src/main/ets/view/VariableWatchView'];
  static readonly GBK_TRANSCODING: string[] = ['@ohos/gbktranscoding', './src/main/ets/pages/FriendsBook'];
  static readonly PHOTO_PICK_AND_SAVE: string[] = ['@ohos/photopickandsave', './src/main/ets/components/PictureManager'];
  static readonly FAULT: string[] = ['@ohos/applicationexception', './src/main/ets/view/ApplicationException'];
  static readonly DARK_MODE: string[] = ['@ohos/fitfordarkmode', './src/main/ets/view/FitForDarkMode'];
  static readonly MARQUEE: string[] = ['@ohos/marquee', './src/main/ets/view/Marquee'];
  static readonly PULL_TO_REFRESH: string[] = ['@ohos/pulltorefreshnews', './src/main/ets/pages/PullToRefreshNews'];
  static readonly PAGE_TURNING_ANIMATION: string[] = ['@ohos/pageturninganimation', './src/main/ets/view/PageTurningAnimation'];
  static readonly VERIFY_CODE: string[] = ['@ohos/verifycode', './src/main/ets/view/VerifyCodeView'];
  static readonly NATIVE_PROGRESS_NOTIFY: string[] = ['@ohos/nativeprogressnotify', './src/main/ets/view/NativeProgressNotify'];
  static readonly VIBRATE_EFFECT: string[] = ['@ohos/vibrateeffect', './src/main/ets/VibrateEffect'];
  static readonly SWIPER_SMOOTH_VARIATION: string[] = ['@ohos/swipersmoothvariation', './src/main/ets/pages/MainPage'];
  static readonly NAVIGATION_BAR_CHANGE: string[] = ['@ohos/navigationbarchange', './src/main/ets/view/NavigationBarChange'];
  static readonly MEDIA_FULL_SCREEN: string[] = ['@ohos/mediafullscreen', './src/main/ets/view/MediaFullScreen'];
  static readonly CITY_SEARCH: string[] = ['@ohos/citysearch', './src/main/ets/view/CitySearch'];
  static readonly WATER_RIPPLES: string[] = ['@ohos/waterripples', './src/main/ets/WaterRipples'];
  static readonly FOLDABLE_SCREEN_CASES: string[] = ['@ohos/foldablescreencases', './src/main/ets/pages/MusicPlayerPage'];
  static readonly IMAGE_COMMENT: string[] = ['@ohos/imagecomment', './src/main/ets/components/view/ImageCommentView'];
  static readonly COMPONENT_TACK: string[] = ['@ohos/componentstack', './src/main/ets/view/ComponentStack.ets'];
  static readonly CUSTOM_CALENDAR_PICKER_DIALOG: string[] = ['@ohos/customcalendarpickerdialog', './src/main/ets/view/CalendarView.ets'];
  static readonly CUSTOM_VIEW: string[] = ['@ohos/customview', './src/main/ets/view/CustomView.ets'];
  static readonly DECOMPRESS_FILE: string[] = ['@ohos/decompressfile', './src/main/ets/view/MainPage.ets'];
  static readonly DRAG_EXCHANGE: string[] = ['@ohos/dragandexchange', './src/main/ets/pages/Launcher.ets'];
  static readonly NATIVE_PICTURE_SANDBOX: string[] = ['@ohos/nativesavepictosandbox', './src/main/ets/view/NativePictureToSandboxView.ets']
  static readonly PAINT_COMPONENT: string[] = ['@ohos/paintcomponent', './src/main/ets/view/PaintComponent'];
}
