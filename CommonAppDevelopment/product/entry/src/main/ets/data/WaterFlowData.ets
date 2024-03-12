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

import { SceneModuleInfo } from '@ohos/functionalscenes';
import { RouterInfo } from '@ohos/dynamicsRouter/Index';
import { UserBookingInfo } from '@ohos/navigationparametertransfer/Index';

const userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
const strUserBooking: string = JSON.stringify(userBooking);

export const waterFlowData: SceneModuleInfo[] = [
  new SceneModuleInfo($r("app.media.bar_chart_top"), 'MpChart图表实现', RouterInfo.BAR_CHAT, '三方库', 1),
  new SceneModuleInfo($r("app.media.address_exchange"), '地址交换动画', RouterInfo.ADDRESS_EXCHANGE, '动效'),
  new SceneModuleInfo($r("app.media.tab_bar"), '自定义TabBar页签', RouterInfo.CUSTOM_TAB_BAR, '动效'),
  new SceneModuleInfo($r("app.media.secondary_linkage"), '列表二级联动', RouterInfo.SECONDARY_LINKAGE, 'UI布局', 1),
  new SceneModuleInfo($r("app.media.raw_file"), '读取RawFile文件部分内容', RouterInfo.READ_RAW_FILE, 'Native'),
  new SceneModuleInfo($r("app.media.event_propagation"), '阻塞事件冒泡', RouterInfo.EVENT_TRANSMISSION_SOLUTION, '其他', 1),
  new SceneModuleInfo($r("app.media.image_viewer"), '图片缩放功能实现', RouterInfo.IMAGE_VIEWER, '其他'),
  new SceneModuleInfo($r("app.media.todo_list"), '列表编辑', RouterInfo.PENDING_ITEMS, 'UI布局', 1),
  new SceneModuleInfo($r("app.media.handle_tabs"), '增删tab页签', RouterInfo.HANDLE_TABS, 'UI布局'),
  new SceneModuleInfo($r("app.media.modal_window"), '全屏登录页面', RouterInfo.MODAL_WINDOW, 'UI布局'),
  new SceneModuleInfo($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', RouterInfo.SLIDE_TO_HIDE_AND_DISPLACE, 'UI布局'),
  new SceneModuleInfo($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', RouterInfo.NAVIGATION_PARAMETER_TRANSFER, '其他', 1, strUserBooking),
  new SceneModuleInfo($r('app.media.aki_use_practice'), 'AKI使用实践', RouterInfo.AKI_USE_PRACTICE, '其他'),
  new SceneModuleInfo($r('app.media.variable_watch'), '多层嵌套类监听', RouterInfo.VARIABLE_WATCH, '其他'),
  new SceneModuleInfo($r('app.media.friends_book'), 'GBK文本格式解码', RouterInfo.GBK_TRANSCODING, '其他'),
  new SceneModuleInfo($r("app.media.photo_pick_and_save"), '图片选择和下载保存', RouterInfo.PHOTO_PICK_AND_SAVE, '其他', 1),
  new SceneModuleInfo($r('app.media.application_exception'), '异常处理', RouterInfo.FAULT, '其他'),
  new SceneModuleInfo($r('app.media.fit_for_dark_mode'), '深浅模式', RouterInfo.DARK_MODE, 'UI布局'),
  new SceneModuleInfo($r('app.media.marquee'), '跑马灯', RouterInfo.MARQUEE, '动效', 3),
  new SceneModuleInfo($r('app.media.pull_to_refresh_news'), '下拉刷新上滑加载', RouterInfo.PULL_TO_REFRESH, '动效'),
  new SceneModuleInfo($r('app.media.page_turning_animation'), '翻页动效', RouterInfo.PAGE_TURNING_ANIMATION, '动效', 3),
  new SceneModuleInfo($r("app.media.verify_code"), '验证码布局案例', RouterInfo.VERIFY_CODE, 'UI布局', 3),
  new SceneModuleInfo($r('app.media.native_progress_notify'), '在Native侧实现进度通知功能', RouterInfo.NATIVE_PROGRESS_NOTIFY, 'Native'),
  new SceneModuleInfo($r('app.media.vibrate_effect'), '使用弹簧曲线实现抖动动画及手机振动效果案例', RouterInfo.VIBRATE_EFFECT, '动效', 1),
  new SceneModuleInfo($r("app.media.swiper_smooth_variation"), 'Swiper高度可变化效果实现', RouterInfo.SWIPER_SMOOTH_VARIATION, '动效'),
  new SceneModuleInfo($r("app.media.navigation_bar_change"), '状态栏显隐变化', RouterInfo.NAVIGATION_BAR_CHANGE, '动效'),
  new SceneModuleInfo($r("app.media.media_fullscreen"), '视频全屏切换', RouterInfo.MEDIA_FULL_SCREEN, 'UI布局'),
  new SceneModuleInfo($r("app.media.city_search"), '选择城市', RouterInfo.CITY_SEARCH, 'UI布局'),
  new SceneModuleInfo($r("app.media.water_ripples"), '听歌识曲水波纹案例', RouterInfo.WATER_RIPPLES, '动效', 1),
  new SceneModuleInfo($r("app.media.music_player"), '折叠屏适配音乐播放器', RouterInfo.FOLDABLE_SCREEN_CASES, '动效', 3),
  new SceneModuleInfo($r("app.media.image_comment"), '发布图片评论', RouterInfo.IMAGE_COMMENT, '其他'),
  new SceneModuleInfo($r("app.media.component_stack"), '组件堆叠', RouterInfo.COMPONENT_TACK, 'UI布局'),
  new SceneModuleInfo($r("app.media.native_image2sandbox"), 'native保存图片到沙箱', RouterInfo.NATIVE_PICTURE_SANDBOX, 'Native'),
  new SceneModuleInfo($r("app.media.custom_view"), '自定义视图实现Tab效果', RouterInfo.CUSTOM_VIEW, 'UI布局'),
  new SceneModuleInfo($r("app.media.drag_and_exchange"), 'Grid和List内拖拽交换子组件位置', RouterInfo.DRAG_EXCHANGE, 'UI布局'),
  new SceneModuleInfo($r("app.media.custom_calendar_picker_dialog"), '自定义日历选择器', RouterInfo.CUSTOM_CALENDAR_PICKER_DIALOG, 'UI布局'),
  new SceneModuleInfo($r("app.media.decompress_file"), 'Worker子线程中解压文件', RouterInfo.DECOMPRESS_FILE, '其他'),
  new SceneModuleInfo($r("app.media.paint_component"), '使用绘制组件实现自定义进度动画', RouterInfo.PAINT_COMPONENT, '动效', 1),
  new SceneModuleInfo($r("app.media.short_video"), '短视频切换', RouterInfo.SHORT_VIDEO, 'UI布局'),
  new SceneModuleInfo($r("app.media.mp_charts"), 'MpChart运动健康', RouterInfo.MP_CHAT, '三方库', 3),
  new SceneModuleInfo($r("app.media.lottie_animation"), 'Lottie', RouterInfo.LOTTIE_VIEW, '其他'),
  new SceneModuleInfo($r("app.media.voting_component"), '投票组件', RouterInfo.VOTING_COMPONENT, '动效', 2),
  new SceneModuleInfo($r("app.media.web_get_camera_image"), 'Web获取相机拍照图片案例', RouterInfo.WEB_GET_CAMERA_IMAGE, '其他'),
  new SceneModuleInfo($r("app.media.number_scroll"), '数字滚动', RouterInfo.DIGITAL_SCROLL_ANIMATION, '动效'),
  new SceneModuleInfo($r("app.media.image_compression"), '图片压缩方案', RouterInfo.IMAGE_COMPRESSION, '其他', 3),
  new SceneModuleInfo($r("app.media.side_bar_animation"), 'SideBarContainer侧边栏淡入淡出动效实现案例', RouterInfo.SIDE_BAR_ANIMATION, '动效'),
  new SceneModuleInfo($r("app.media.image_enableanalyzer"), '图片拖拽AI抠图案例', RouterInfo.IMAGE_ENABLE_ANALYZER, '其他', 1),
  new SceneModuleInfo($r("app.media.Chinese_to_pinyin"), '汉字转拼音案例', RouterInfo.CHINESE_TO_PINYIN, '其他', 1),
  new SceneModuleInfo($r("app.media.bottom_drawer_slide"), '底部抽屉滑动效果案例', RouterInfo.BOTTOM_DRAWER_SLIDE_CASE, '动效', 1),
  new SceneModuleInfo($r("app.media.expand_title"), '标题下拉缩放案例', RouterInfo.EXPAND_TITLE, '动效', 1),
  new SceneModuleInfo($r("app.media.list_slide_to_history"), '长列表滑动到指定列表项动效实现案例', RouterInfo.LIST_SLIDE_TO_HISTORY, '动效', 1),
  new SceneModuleInfo($r("app.media.page_loading"), '页面加载效果实现案例', RouterInfo.PAGE_LOADING, '动效', 1),
  new SceneModuleInfo($r("app.media.big_file_copy"), '大文件拷贝案例', RouterInfo.BIG_FILE_COPY, '其他', 1),
  new SceneModuleInfo($r("app.media.digging_hole_screen"), '适配挖孔屏案例', RouterInfo.DIGGING_HOLE_SCREEN, 'UI布局'),
  new SceneModuleInfo($r("app.media.drag_to_switch_pictures"), '左右拖动切换图片效果案例', RouterInfo.DRAG_TO_SWITCH_PICTURES, 'UI布局'),
  new SceneModuleInfo($r("app.media.listitem_overflow"), '元素超出List区域', RouterInfo.LIST_ITEM_OVERFLOW, 'UI布局'),
  new SceneModuleInfo($r("app.media.componentinstancesharedinpages"), '页面间共享组件实例的案例', RouterInfo.COMPONENT_SHARED_IN_PAGES, 'UI布局'),
  new SceneModuleInfo($r("app.media.custom_safe_keyboard"), '自定义安全键盘案例', RouterInfo.CUSTOM_SAFE_KEYBOARD, 'UI布局'),
  new SceneModuleInfo($r("app.media.database_upgrade"), '数据库版本升级案例', RouterInfo.DATABASE_UPGRADE, '其他', 3),
  new SceneModuleInfo($r("app.media.image_enableanalyzer"), '图片拖拽AI抠图案例', RouterInfo.IMAGE_ENABLE_ANALYZER, '其他', 1),
  new SceneModuleInfo($r("app.media.transition_animation"), '一镜到底“页面转场”动画', RouterInfo.TRANSITION_ANIMATION, '动效', 2)
]