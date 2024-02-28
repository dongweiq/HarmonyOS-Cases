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
 * 实现：
 * 1. 取消SideBarConatiner组件的默认按钮，通过自定义按钮+显式动画实现侧边栏动画
 * 2. 将动效相关属性与侧边栏的显隐相关联
 */

import { SideBarView } from './SideBarView';
import { SideBarContentView } from './SideBarContentView';
import { SideBarAnimationViewConstants } from '../constants/SideBarAnimationViewConstants';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';
import deviceInfo from '@ohos.deviceInfo';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct SideBarAnimationView {
  @State isShowSideBar: boolean = false;
  sidebarType: SideBarContainerType = SideBarContainerType.Embed;

  setPhoneWindowOrientation(orientation: window.Orientation): void {
    window.getLastWindow(getContext(this), (err: BusinessError, data: window.Window) => {
      if (deviceInfo.deviceType === "phone") {
        data.setPreferredOrientation(orientation);
      }
    })
  }

  aboutToAppear(): void {
    this.setPhoneWindowOrientation(window.Orientation.LANDSCAPE_INVERTED);
  }

  aboutToDisappear(): void {
    this.setPhoneWindowOrientation(window.Orientation.PORTRAIT);
  }

  build() {
    SideBarContainer(this.sidebarType) {
      /**
       * TODO：知识点：这里自定义了Opacity的动画，注意，因为本方案使用的是显式动画，
       * 且通过显式动画对this.isShowSideBar进行了变化，因此相关动画属性均需要与this.isShowSideBar进行关联，
       * 动画的实现见SideBarContentView中的switchTabBar方法
       */
      SideBarView()
        .opacity(this.isShowSideBar ? SideBarAnimationViewConstants.SIDEBAR_OPACITY_SHOW : SideBarAnimationViewConstants.SIDEBAR_OPACITY_HIDDEN)
        .borderRadius($r("sys.float.ohos_id_corner_radius_default_m"))

      SideBarContentView({ isShowSideBar: this.isShowSideBar })
        .width($r("app.string.full_size"))
    }
    .divider(null)
    .sideBarPosition(SideBarPosition.End)
    // TODO：知识点：通过showSideBar属性控制侧边栏的显隐，以便定制动效
    .showSideBar(this.isShowSideBar)
    // TODO：知识点：由于SideBarContainer的默认按钮无法定制动效，所以需要隐藏掉，通过自定义按钮进行动画的控制
    .showControlButton(SideBarAnimationViewConstants.SIDEBAR_IS_SHOW_BUTTON)
    .sideBarWidth(SideBarAnimationViewConstants.SIDEBAR_WIDTH)
    .autoHide(SideBarAnimationViewConstants.SIDEBAR_IS_AUTO_HIDE)
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
    .padding($r('sys.float.ohos_id_card_margin_start'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getSideBarAnimationView(): void {
  SideBarAnimationView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.SIDE_BAR_ANIMATION,wrapBuilder(getSideBarAnimationView));