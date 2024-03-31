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
import CustomScanCameraComp from '../components/CustomScanCameraComp';
import CustomScanCtrlComp from '../components/CustomScanCtrlComp';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';

/**
 * 二维码扫描页面
 * 实现步骤：
 * 1.用户授权相机后初始化页面内子组件
 * 2.进二维码扫描路由时监控折叠屏状态变化，实时重新初始化扫码服务和相机流尺寸
 */
@Component
export struct CustomScanPage {
  // 自定义扫码vm实例
  private customScanVM: CustomScanViewModel = CustomScanViewModel.getInstance();
  // 授权标志
  @State isGranted: boolean = false;

  async aboutToAppear() {
    // 进入窗口沉浸式
    this.customScanVM.setMainWindowImmersive(true);

    // TODO：知识点：检测应用是否已被用户允许使用相机权限，未授权向申请授权
    const isGranted = await this.customScanVM.reqCameraPermission();
    if (!isGranted) {
      // 用户未授权，给出提示
      this.customScanVM.showPermissionDenied();
    }
    this.isGranted = isGranted;
  }

  aboutToDisappear() {
    // 退出窗口沉浸式
    this.customScanVM.setMainWindowImmersive(false);
  }

  build() {
    Stack() {
      if (this.isGranted) {
        CustomScanCameraComp()
        CustomScanCtrlComp()
      }
    }
    .alignContent(Alignment.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}

/**
 * 创建WrappedBuilder对象，动态路由跳转时构建页面
 */
@Builder
export function getCustomScanPage(): void {
  CustomScanPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.CUSTOM_SCAN, wrapBuilder(getCustomScanPage));