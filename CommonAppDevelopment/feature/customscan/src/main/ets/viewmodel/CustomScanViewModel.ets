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

import { display, promptAction, window } from '@kit.ArkUI';
import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';

import { logger } from '@ohos/utils';

import CommonConstants from '../common/constants/CommonConstants';
import PermissionModel from '../model/PermissionModel';
import WindowModel from '../model/WindowModel';

export default class CustomScanViewModel {
  /**
   * 单例模型私有化构造函数，使用getInstance静态方法获得单例
   */
  private constructor() {
    // 初始化窗口管理model
    const windowStage: window.WindowStage | undefined = AppStorage.get('windowStage');
    if (windowStage) {
      this.windowModel.setWindowStage(windowStage);
    }

    // 初始化相机流尺寸
    this.updateCameraCompSize();
  }

  /**
   * CustomScanViewModel 单例
   */
  private static instance?: CustomScanViewModel;

  /**
   * 获取CustomScanViewModel单例实例
   * @returns {CustomScanViewModel} CustomScanViewModel
   */
  static getInstance(): CustomScanViewModel {
    if (!CustomScanViewModel.instance) {
      CustomScanViewModel.instance = new CustomScanViewModel();
    }

    return CustomScanViewModel.instance;
  }

  /**
   * PermissionModel 单例
   */
  private permissionModel: PermissionModel = PermissionModel.getInstance();

  /**
   * WindowModel 单例
   */
  private windowModel: WindowModel = WindowModel.getInstance();

  /**
   * 自定义扫码初始化配置参数
   */
  private customScanInitOptions: scanBarcode.ScanOptions = {
    scanTypes: [ scanCore.ScanType.QR_CODE ],
    enableMultiMode: true,
    enableAlbum: true
  }

  /**
   * 当前屏幕折叠态（仅折叠屏设备下有效）
   */
  curFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;

  /**
   * 相机流展示组件（XComponent）的surfaceId
   */
  surfaceId: string = '';

  /**
   * 相机流展示组件（XComponent）的宽
   */
  cameraCompWidth: number = 0;

  /**
   * 相机流展示组件（XComponent）的高
   */
  cameraCompHeight: number = 0;

  /**
   * 相机流展示组件内容尺寸修改回调函数
   */
  cameraCompSizeUpdateCb: Function = (): void => {};

  /**
   * 相机闪光灯状态更新回调函数
   */
  cameraLightUpdateCb: Function = (): void => {};

  /**
   * 检测是否有相机权限，未授权尝试申请授权
   * @returns {Promise<boolean>} 相机权限/授权结果
   */
  async reqCameraPermission(): Promise<boolean> {
    const reqPermissionName = CommonConstants.PERMISSION_CAMERA;
    // 优先检测是否已授权
    let isGranted = await this.permissionModel.checkPermission(reqPermissionName);
    if (isGranted) {
      return true;
    }
    // 没有授权申请授权
    isGranted = await this.permissionModel.requestPermission(reqPermissionName);
    return isGranted;
  }

  /**
   * 当前主窗口是否开启沉浸模式
   * @param {boolean} enable 是否开启
   * @returns {void}
   */
  setMainWindowImmersive(enable: boolean): void {
    this.windowModel.setMainWindowImmersive(enable);
  }

  /**
   * 更新相机流展示组件（XComponent）的尺寸
   * @returns {void}
   */
  async updateCameraCompSize(): Promise<void> {
    // 通过窗口属性修改组件宽高，窗口属性返回的宽高单位为px，需要转换成vp供customScan的start接口使用
    const mainWinRect = await this.windowModel.getWindowRect();
    if (mainWinRect) {
      this.cameraCompWidth = px2vp(mainWinRect.width);
      this.cameraCompHeight = px2vp(mainWinRect.height);
    }

    logger.debug(`updateCameraCompSize: width=${this.cameraCompWidth} height=${this.cameraCompHeight}`);
  }

  /**
   * 注册屏幕状态监听
   * @returns {void}
   */
  regDisplayListener(): void {
    if (display.isFoldable()) {
      // 监听折叠屏状态变更，更新折叠态，修改窗口显示方向
      display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
        // 同一个状态重复触发不做处理
        if (this.curFoldStatus === curFoldStatus) {
          return;
        }

        // 缓存当前折叠状态
        this.curFoldStatus = curFoldStatus;

        if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED
            || this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
          // 当前没有相机流资源，只更新相机流宽高设置
          if (!this.surfaceId) {
            this.updateCameraCompSize();
            return;
          }

          // 关闭闪光灯
          this.tryCloseFlashLight();
          setTimeout(() => {
            // 释放扫码资源
            this.releaseCustomScan();
            // 重新启动扫码
            this.restartCustomScan();
          }, 10)
        }
      })
    }
  }

  /**
   * 注册相机流展示组件内容尺寸修改回调函数
   * @param {Function} callback 相机流展示组件内容尺寸修改回调函数
   * @returns {void}
   */
  regXCompSizeUpdateListener(callback: Function): void {
    this.cameraCompSizeUpdateCb = callback;
  }

  /**
   * 注册相机闪光灯状态更新回调函数
   * @param {Function} callback 相机闪光灯状态更新回调函数
   * @returns {void}
   */
  regCameraLightUpdateListener(callback: Function): void {
    this.cameraLightUpdateCb = callback;
  }

  /**
   * 更新相机闪光灯状态
   * @returns {void}
   */
  updateFlashLightStatus(): void {
    // 根据当前闪光灯状态，选择打开或关闭闪关灯
    try {
      let isCameraLightOpen: boolean = false;
      console.log("getFlashLightStatus: ", customScan.getFlashLightStatus())
      if (customScan.getFlashLightStatus()) {
        customScan.closeFlashLight();
        isCameraLightOpen = false;
      } else {
        customScan.openFlashLight();
        isCameraLightOpen = true;
      }

      this.cameraLightUpdateCb(isCameraLightOpen);
    } catch (error) {
      logger.error('flashLight control failed, error: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 尝试把开启的闪光灯关闭
   * @returns {void}
   */
  tryCloseFlashLight() {
    try {
      // 闪光灯标记移除
      this.cameraLightUpdateCb(false);
      // 如果闪光灯开启，则关闭
      if (customScan.getFlashLightStatus()) {
        customScan.closeFlashLight();
      }
    } catch (error) {
      logger.error('flashLight try close failed, error: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 初始化自定义扫码
   * @returns {void}
   */
  initCustomScan(): void {
    try {
      customScan.init(this.customScanInitOptions);
    } catch (error) {
      logger.error('init fail, error: %{public}s ', JSON.stringify(error));
    }
  }

  /**
   * 启动自定义扫码
   * @returns {void}
   */
  startCustomScan(): void {
    try {
      const viewControl: customScan.ViewControl = {
        width: this.cameraCompWidth,
        height: this.cameraCompHeight,
        surfaceId: this.surfaceId
      };
      customScan.start(viewControl)
        .then((result: Array<scanBarcode.ScanResult>) => {
          // 处理扫码结果
          this.showScanResult(result);
        })
    } catch (error) {
      logger.error('start fail, error: %{public}s ', JSON.stringify(error));
    }
  }

  /**
   * 停止自定义扫码
   * @returns {void}
   */
  stopCustomScan(): void {
    try {
      customScan.stop().then(() => {
      }).catch((error: BusinessError) => {
        logger.error('stop failed error: %{public}s ', JSON.stringify(error));
      })
    } catch (error) {
      logger.error('Catch: stop error %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 释放自定义扫码资源
   * @returns {void}
   */
  releaseCustomScan(): void {
    try {
      customScan.release().then(() => {
      }).catch((error: BusinessError) => {
        logger.error('release failed error: %{public}s ', JSON.stringify(error));
      })
    } catch (error) {
      logger.error('Catch: release error %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 重新启动扫码
   * @returns {void}
   */
  async restartCustomScan(): Promise<void> {
    // 根据窗口尺寸调整展示组件尺寸
    await this.updateCameraCompSize();
    // 调整相机surface尺寸
    this.cameraCompSizeUpdateCb(this.cameraCompWidth, this.cameraCompHeight);
    // 初始化相机资源
    this.initCustomScan();
    // 重新启动扫描
    this.startCustomScan();
  }

  /**
   * 显示扫码结果
   * @param {Array<scanBarcode.ScanResult>} result 扫码结果数据
   * @returns {void}
   */
  showScanResult(scanResult: Array<scanBarcode.ScanResult>): void {
    // 关闭相机闪光灯
    this.tryCloseFlashLight();

    if (scanResult.length > 0) {
      // 获取到扫描结果后暂停相机流
      setTimeout(() => {
        this.stopCustomScan();
      }, 10)

      let showMsg: string = '';

      // 处理扫码结果
      scanResult.forEach((result: scanBarcode.ScanResult) => {
        // 码源信息
        const originalValue: string = result.originalValue;
        // 二维码在屏幕上的位置
        const scanCodeRect: scanBarcode.ScanCodeRect | undefined = result.scanCodeRect;

        if (scanCodeRect) {
          showMsg += `内容: ${originalValue}\n坐标: ${JSON.stringify(scanCodeRect)}\n`;
        }
      })

      // 使用toast显示出扫码结果
      promptAction.showDialog({
        title: $r('app.string.tips_scan_result_title'),
        message: showMsg,
        buttons: [
          {
            text: $r('app.string.text_btn_restart_scan'),
            color: $r('app.string.color_black'),
          },
        ],
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0 , dy: -10 },
        isModal: true,
        showInSubWindow: true,
      }, (err, data) => {
        if (err) {
          logger.error('showDialog err: ' + err);
          return;
        }
        // 重新扫码
        this.startCustomScan();
      });
    }
  }

  /**
   * 显示未授权toast
   * @returns {void}
   */
  showPermissionDenied(): void {
    promptAction.showToast({
      message: $r('app.string.tips_camera_permissions_denied'),
      duration: CommonConstants.TOAST_PERMISSIONS_DENIED
    });
  }

  /**
   * 打开系统相册（待开发）
   * @returns {void}
   */
  openSysPicture(): void {
    // TODO：需求：打开系统相册
    promptAction.showToast({
      message: $r('app.string.toast_sys_pic'),
      duration: CommonConstants.TOAST_PERMISSIONS_DENIED
    });
  }
}


