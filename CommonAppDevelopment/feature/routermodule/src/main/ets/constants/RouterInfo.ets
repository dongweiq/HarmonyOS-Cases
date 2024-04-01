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
  moduleName: string = '';
  pageName: string = '';

  constructor(moduleName: string, pageName: string) {
    this.moduleName = moduleName;
    this.pageName = pageName;
  }

  static readonly HOME_PAGE: RouterInfo = new RouterInfo('@ohos/entry', 'EntryView');
  static readonly ADDRESS_EXCHANGE: RouterInfo = new RouterInfo('@ohos/addressexchange', 'AddressExchangeView');
  static readonly BAR_CHAT: RouterInfo = new RouterInfo('@ohos/barchart', 'BarChart');
  static readonly CUSTOM_TAB_BAR: RouterInfo = new RouterInfo('@ohos/customtabbar', 'TabView');
  static readonly SECONDARY_LINKAGE: RouterInfo = new RouterInfo('@ohos/secondarylinkage', 'SecondaryLinkExample');
  static readonly READ_RAW_FILE: RouterInfo = new RouterInfo('@ohos/nativerawfile', 'MainPage');
  static readonly EVENT_TRANSMISSION_SOLUTION: RouterInfo = new RouterInfo('@ohos/eventpropagation', 'EventPropagation');
  static readonly IMAGE_VIEWER: RouterInfo = new RouterInfo('@ohos/imageviewer', 'ImageViewerView');
  static readonly PENDING_ITEMS: RouterInfo = new RouterInfo('@ohos/pendingitems', 'ToDoList');
  static readonly HANDLE_TABS: RouterInfo = new RouterInfo('@ohos/handletabs', 'HandleTabs');
  static readonly MODAL_WINDOW: RouterInfo = new RouterInfo('@ohos/modalwindow', 'ModalWindow');
  static readonly SLIDE_TO_HIDE_AND_DISPLACE: RouterInfo = new RouterInfo('@ohos/slidetohideanddisplace', 'SlideToHideAndDisplace');
  static readonly NAVIGATION_PARAMETER_TRANSFER: RouterInfo = new RouterInfo('@ohos/navigationparametertransfer', 'NavigationParameterTransferView');
  static readonly AKI_USE_PRACTICE: RouterInfo = new RouterInfo('@ohos/akiusepractice', 'AkiView');
  static readonly VARIABLE_WATCH: RouterInfo = new RouterInfo('@ohos/variablewatch', 'VariableWatchView');
  static readonly GBK_TRANSCODING: RouterInfo = new RouterInfo('@ohos/gbktranscoding', 'FriendsBook');
  static readonly PHOTO_PICK_AND_SAVE: RouterInfo = new RouterInfo('@ohos/photopickandsave', 'PictureManager');
  static readonly FAULT: RouterInfo = new RouterInfo('@ohos/applicationexception', 'ApplicationException');
  static readonly DARK_MODE: RouterInfo = new RouterInfo('@ohos/fitfordarkmode', 'FitForDarkMode');
  static readonly MARQUEE: RouterInfo = new RouterInfo('@ohos/marquee', 'Marquee');
  static readonly PULL_TO_REFRESH: RouterInfo = new RouterInfo('@ohos/pulltorefreshnews', 'PullToRefreshNews');
  static readonly PAGE_TURNING_ANIMATION: RouterInfo = new RouterInfo('@ohos/pageturninganimation', 'PageTurningAnimation');
  static readonly VERIFY_CODE: RouterInfo = new RouterInfo('@ohos/verifycode', 'VerifyCodeView');
  static readonly NATIVE_PROGRESS_NOTIFY: RouterInfo = new RouterInfo('@ohos/nativeprogressnotify', 'NativeProgressNotify');
  static readonly VIBRATE_EFFECT: RouterInfo = new RouterInfo('@ohos/vibrateeffect', 'VibrateEffect');
  static readonly SWIPER_SMOOTH_VARIATION: RouterInfo = new RouterInfo('@ohos/swipersmoothvariation', 'MainPage');
  static readonly NAVIGATION_BAR_CHANGE: RouterInfo = new RouterInfo('@ohos/navigationbarchange', 'NavigationBarChange');
  static readonly MEDIA_FULL_SCREEN: RouterInfo = new RouterInfo('@ohos/mediafullscreen', 'MediaFullScreen');
  static readonly CITY_SEARCH: RouterInfo = new RouterInfo('@ohos/citysearch', 'CitySearch');
  static readonly WATER_RIPPLES: RouterInfo = new RouterInfo('@ohos/waterripples', 'WaterRipples');
  static readonly FOLDABLE_SCREEN_CASES: RouterInfo = new RouterInfo('@ohos/foldablescreencases', 'MusicPlayerPage');
  static readonly IMAGE_COMMENT: RouterInfo = new RouterInfo('@ohos/imagecomment', 'ImageCommentView');
  static readonly COMPONENT_TACK: RouterInfo = new RouterInfo('@ohos/componentstack', 'ComponentStack.ets');
  static readonly CUSTOM_CALENDAR_PICKER_DIALOG: RouterInfo = new RouterInfo('@ohos/customcalendarpickerdialog', 'CalendarView');
  static readonly CUSTOM_VIEW: RouterInfo = new RouterInfo('@ohos/customview', 'CustomView.ets');
  static readonly DECOMPRESS_FILE: RouterInfo = new RouterInfo('@ohos/decompressfile', 'MainPage');
  static readonly DRAG_EXCHANGE: RouterInfo = new RouterInfo('@ohos/dragandexchange', 'Launcher');
  static readonly WEB_GET_CAMERA_IMAGE: RouterInfo = new RouterInfo('@ohos/webgetcameraimage', 'MainPage');
  static readonly NATIVE_PICTURE_SANDBOX: RouterInfo = new RouterInfo('@ohos/nativesavepictosandbox', 'NativePictureToSandboxView');
  static readonly PAINT_COMPONENT: RouterInfo = new RouterInfo('@ohos/paintcomponent', 'PaintComponent');
  static readonly SHORT_VIDEO: RouterInfo = new RouterInfo('@ohos/shortvideo', 'ShortVideo');
  static readonly MP_CHAT: RouterInfo = new RouterInfo('@ohos/barchart', 'MpCharts');
  static readonly DIGITAL_SCROLL_ANIMATION: RouterInfo = new RouterInfo('@ohos/digitalscrollanimation', 'DigitalScrollDetail');
  static readonly LOTTIE_VIEW: RouterInfo = new RouterInfo('@ohos/lottieview', 'LottieView');
  static readonly VOTING_COMPONENT: RouterInfo = new RouterInfo('@ohos/votingcomponent', 'VotingComponent');
  static readonly SIDE_BAR_ANIMATION: RouterInfo = new RouterInfo('@ohos/sidebaranimation', 'SideBarAnimationView');
  static readonly IMAGE_COMPRESSION: RouterInfo = new RouterInfo('@ohos/imagecompression', 'ImageCompression');
  static readonly IMAGE_ENABLE_ANALYZER: RouterInfo = new RouterInfo('@ohos/imageenableanalyzer', 'ImageView');
  static readonly CHINESE_TO_PINYIN: RouterInfo = new RouterInfo('@ohos/chinesetopinyin', 'ChineseToPinyin');
  static readonly BOTTOM_DRAWER_SLIDE_CASE: RouterInfo = new RouterInfo('@ohos/bottomdrawerslidecase', 'BottomDrawerSlideCase');
  static readonly EXPAND_TITLE: RouterInfo = new RouterInfo('@ohos/expandtitle', 'TitleExpansion');
  static readonly LIST_SLIDE_TO_HISTORY: RouterInfo = new RouterInfo('@ohos/listslidetohistory', 'ListSlideToHistory');
  static readonly PAGE_LOADING: RouterInfo = new RouterInfo('@ohos/pageloading', 'PageLoading');
  static readonly BIG_FILE_COPY: RouterInfo = new RouterInfo('@ohos/bigfilecopy', 'BigFileCopyView');
  static readonly DIGGING_HOLE_SCREEN: RouterInfo = new RouterInfo('@ohos/diggingholescreen', 'DiggingHoleScreen');
  static readonly DRAG_TO_SWITCH_PICTURES: RouterInfo = new RouterInfo('@ohos/dragtoswitchpictures', 'DragToSwitchPictures');
  static readonly LIST_ITEM_OVERFLOW: RouterInfo = new RouterInfo('@ohos/listitemoverflow', 'AboutMe');
  static readonly COMPONENT_SHARED_IN_PAGES: RouterInfo = new RouterInfo('@ohos/componentinstancesharedinpages', 'ComponentSharedInPages');
  static readonly CUSTOM_SAFE_KEYBOARD: RouterInfo = new RouterInfo('@ohos/customsafekeyboard', 'CustomSafeKeyboardView');
  static readonly DATABASE_UPGRADE: RouterInfo = new RouterInfo('@ohos/databaseupgrade', 'DatabaseUpgrade');
  static readonly TRANSITION_ANIMATION: RouterInfo = new RouterInfo('@ohos/transitionanimation', 'TransitionAnimation');
  static readonly TRANSITION_ANIMATION_SUB_Detail: RouterInfo = new RouterInfo('@ohos/transitionanimation', 'SubDetailPage');
  static readonly IMAGE_GRID_LAYOUT: RouterInfo = new RouterInfo('@ohos/imagegridlayout', 'ImageGridLayout');
  static readonly DYNAMIC_ATTRIBUTES: RouterInfo = new RouterInfo('@ohos/dynamicattributes', 'ShoppingCart');
  static readonly DYNAMIC_ATTRIBUTES_DETAILS: RouterInfo = new RouterInfo('@ohos/dynamicattributes', 'Details');
  static readonly ETS_WRAPPER: RouterInfo = new RouterInfo('@ohos/etswrapper', 'MockNativeCallPickerView');
  static readonly HAND_WRITING_TO_IMAGE: RouterInfo = new RouterInfo('@ohos/handwritingtoimage', 'HandWritingToImage');
  static readonly INDICATOR_BELOW_SWIPER: RouterInfo = new RouterInfo('@ohos/indicatorbelowswiper', 'IndicatorBelowSwiper');
  static readonly MULTI_MODAL_TRANSITION: RouterInfo = new RouterInfo('@ohos/multimodaltransion', 'HalfModalWindow');
  static readonly MULTIPLE_FILES_DOWNLOAD: RouterInfo = new RouterInfo('@ohos/multiplefilesdownload', 'MultipleFilesDownload');
  static readonly NATIVE_EMBED: RouterInfo = new RouterInfo('@ohos/nativeembed', 'NativeEmbedView');
  static readonly SIDE_SLIP_INTERCEPT: RouterInfo = new RouterInfo('@ohos/sideslipintercept', 'MainPage');
  static readonly WEB_PDF_VIEWER: RouterInfo = new RouterInfo('@ohos/webpdfviewer', 'WebPDFViewer');
  static readonly IMAGE_THEFT: RouterInfo = new RouterInfo('@ohos/imagetheft', 'ImageTheft');
  static readonly CARD_SWIPER: RouterInfo = new RouterInfo('@ohos/cardswiperanimation', 'CardSwiperAnimation');
  static readonly FONT_DYNAMIC_REGISTRATION: RouterInfo = new RouterInfo('@ohos/fontdynamicregistration', 'FontDynamicRegistration');
  static readonly CUSTOM_SCAN: RouterInfo = new RouterInfo('@ohos/customscan', 'CustomScanPage');
  static readonly IMAGE_DEPTH_COPY: RouterInfo = new RouterInfo('@ohos/imagedepthcopy', 'ImageDepthCopy');
  static readonly PAGE_FLIP: RouterInfo = new RouterInfo('@ohos/pageflip', 'PageFlip');
  static readonly VIDEO_CACHE: RouterInfo = new RouterInfo('@ohos/videocache', 'VideoCacheView');
  static readonly ICON_MAIN_COLOR: RouterInfo = new RouterInfo('@ohos/iconmaincolor', 'MainPage');
  static readonly EFFECT_KIT: RouterInfo = new RouterInfo('@ohos/effectKit', 'MainPage');
  static readonly HIGH_LIGHT_GUIDE: RouterInfo = new RouterInfo('@ohos/highlightguide', 'Index');
  static readonly WORD_RECOGNITION: RouterInfo = new RouterInfo('@ohos/wordrecognition', 'WordRecognition');
}
