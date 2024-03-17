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

import CustomScanViewModel from '../viewmodel/CustomScanViewModel';
import CommonConstants from '../common/constants/CommonConstants';

/**
 * 扫码相机流组件
 * 实现步骤：
 * 1.使用XComponent展示相机流内容
 * 2.XComponent加载完成之后开启扫码服务
 * 3.监控应用前后台切换、折叠屏状态变更，释放和重启扫码服务
 */
@Component
export default struct CustomScanCameraComp {
  // 应用前后台标记
  @StorageProp('isBackground') @Watch('onBackgroundUpdate') isBackground: boolean = false;
  // 自定义扫码vm实例
  @State customScanVM: CustomScanViewModel = CustomScanViewModel.getInstance();
  // 相机流展示组件控制器
  private cameraSurfaceController: XComponentController = new XComponentController();

  aboutToAppear() {
    // 初始化相机流
    this.customScanVM.initCustomScan();
    // 注册屏幕状态监听（仅折叠屏）
    this.customScanVM.regDisplayListener();
    // 注册XComp尺寸修改回调
    this.customScanVM.regXCompSizeUpdateListener((width: number, height: number) => {
      this.updateCameraSurfaceSize(width, height);
    });
  }

  aboutToDisappear() {
    // 释放相机流
    this.customScanVM.releaseCustomScan();
    // 清除surfaceId
    this.customScanVM.surfaceId = '';
  }

  build() {
    Column() {
      // TODO：知识点：相机流显示依赖XComponent
      XComponent({
        id: CommonConstants.CAMERA_XCOMPONENT_ID,
        type: CommonConstants.CAMERA_XCOMPONENT_TYPE,
        controller: this.cameraSurfaceController
      })
        .onLoad(() => {
          // TODO：知识点：customScan依赖XComponent组件的surfaceId，对图像进行扫描
          this.customScanVM.surfaceId = this.cameraSurfaceController.getXComponentSurfaceId();
          // TODO：知识点：XComponent加载完成后，启动相机进行扫码
          this.customScanVM.startCustomScan();
        })
        // 预览流宽、高，默认单位vp，支持px、lpx、vp
        .width(this.customScanVM.cameraCompWidth)
        .height(this.customScanVM.cameraCompHeight)
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 应用前后台切换回调，进后台时需要释放扫码资源，进前台时需要重启扫码功能
   * @returns {void}
   */
  onBackgroundUpdate(): void {
    if (this.isBackground) {
      this.customScanVM.releaseCustomScan();
    } else {
      this.customScanVM.restartCustomScan();
    }
  }

  /**
   * 动态更新XComponent的Suerface尺寸
   * @param {number} width 新宽度
   * @param {number} height 新高度
   * @returns {void}
   */
  updateCameraSurfaceSize(width: number, height: number): void {
    this.cameraSurfaceController.setXComponentSurfaceSize({
      surfaceWidth: width,
      surfaceHeight: height,
    })
  }
}
