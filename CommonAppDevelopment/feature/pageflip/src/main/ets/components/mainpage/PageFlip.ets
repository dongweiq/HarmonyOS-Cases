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
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { CONFIGURATION, STRINGCONFIGURATION } from '../../common/Constants';
import { BottomView } from '../../view/BottomView';
import { CoverFlipPage } from '../../view/CoverFlipPage';
import { LeftRightPlipPage } from '../../view/LeftRightFlipPage';
import { UpDownFlipPage } from '../../view/UpDownFlipPage';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

/**
 * 创建一个Stack组件，上下菜单通过zIndex在阅读页面之上。
 * 通过底部点击的按钮名来确定翻页方式，创建翻页组件。
 */
@Component
export struct PageFlip {
  @State isMenuViewVisible: boolean = false; // 用来判断上下菜单视图是否显示。
  @State buttonClickedName: string = '左右翻页'; // 点击按钮的名称。
  @State filledName: string = '';
  @State isVisible: boolean = false; // 用来判断翻页方式视图是否显示。
  @State isCommentVisible: boolean = false; // 用来判断评论视图是否显示。
  @State currentPageNum: number = 1; // 书籍在第几页。
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async setSystemBarHidden() {
    let windowClass = await window.getLastWindow(this.context)
    //设置导航栏，状态栏不可见
    await windowClass.setWindowSystemBarEnable([])
  }

  async setSystemBarVisible() {
    let windowClass = await window.getLastWindow(this.context)
    //设置导航栏，状态栏不可见
    await windowClass.setWindowSystemBarEnable(['status'])
  }

  aboutToAppear(): void {
    this.setSystemBarHidden()
  }

  aboutToDisappear(): void {
    this.setSystemBarVisible()
  }

  build() {
    Stack() {
      if (this.buttonClickedName === STRINGCONFIGURATION.LEFTRIGHTFLIPPAGENAME) {
        LeftRightPlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          isCommentVisible: this.isCommentVisible,
          currentPageNum: this.currentPageNum
        });
      } else if (this.buttonClickedName === STRINGCONFIGURATION.UPDOWNFLIPPAGENAME) {
        UpDownFlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          isCommentVisible: this.isCommentVisible,
          currentPageNum: this.currentPageNum
        });
      } else {
        CoverFlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          isCommentVisible: this.isCommentVisible,
          currentPageNum: this.currentPageNum
        });
      }
      Column() {
        BottomView({
          isMenuViewVisible: this.isMenuViewVisible,
          buttonClickedName: this.buttonClickedName,
          filledName: this.filledName,
          isVisible: this.isVisible,
          isCommentVisible: this.isCommentVisible,
        })
          .zIndex(CONFIGURATION.FLIPPAGEZINDEX)
      }
      .height($r('app.string.pageflip_full_size'))
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        /**
         * 弹出上下菜单视图时，由于Column中间无组件，
         * 点击事件会被下一层的LeftRightPlipPage或UpDownFlipPage或CoverFlipPage的点击事件取代。
         */
        this.isMenuViewVisible = false;
        this.filledName = '';
        this.isVisible = false;
      })
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getEventPropagation(): void {
  PageFlip();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.PAGE_FLIP, wrapBuilder(getEventPropagation));