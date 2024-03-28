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

/**
 * 通用常量
 */
export default class CommonConstants {
  /**
   * 相机权限名称
   */
  static readonly PERMISSION_CAMERA = 'ohos.permission.CAMERA';

  /**
   * 相机流展示组件（XComponent）唯一标识
   */
  static readonly CAMERA_XCOMPONENT_ID = 'camera_xcomponent_id';
  /**
   * 相机流展示组件（XComponent）类型
   */
  static readonly CAMERA_XCOMPONENT_TYPE = 'surface';

  /**
   * 相机权限未授权提示持续时间
   */
  static readonly TOAST_PERMISSIONS_DENIED = 2000;
  /**
   * 关闭扫描按钮尺寸
   */
  static readonly SCAN_CTRL_BTN_CLOSE_SIZE = 30;
  /**
   * 闪光灯按钮尺寸
   */
  static readonly SCAN_CTRL_BTN_LIGHT_SIZE = 40;
  /**
   * 扫描动画组件宽度
   */
  static readonly SCAN_DIVIDER_STROKE_WIDTH = 2;
  /**
   * 扫描动画组件起点偏移量
   */
  static readonly SCAN_DIVIDER_OFFSET_BEGIN = 0;
  /**
   * 扫描动画组件终点偏移量
   */
  static readonly SCAN_DIVIDER_OFFSET_END = 400;
  /**
   * 扫描动画组件起点透明度
   */
  static readonly SCAN_DIVIDER_OPACITY_BEGIN = 1;
  /**
   * 扫描动画组件终点透明度
   */
  static readonly SCAN_DIVIDER_OPACITY_END = 0;

  /**
   * 扫描动画配置
   */
  static readonly SCAN_ANI_CONFIG: AnimateParam = {
    duration: 1000, // 动画时间
    tempo: 0.5, // 动画速率
    curve: Curve.EaseInOut,
    iterations: -1, // 动画是否重复播放
    playMode: PlayMode.Normal,
  }
}

