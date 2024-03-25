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
import { BottomView } from '../../view/BottomView';
import { CoverFlipPage } from '../../view/CoverFlipPage';
import { LeftRightPlipPage } from '../../view/LeftRightFlipPage';
import { TopView } from '../../view/TopView';
import { UpDownFlipPage } from '../../view/UpDownFlipPage';

@Component
export struct PageFlip {
  @State isMenuViewVisible: boolean = false; // 用来判断上下菜单视图是否显示。
  @State buttonClickedName: string = '左右翻页'; // 点击按钮的名称。
  @State filledName: string = '';
  @State isVisible: boolean = false; // 用来判断翻页方式视图是否显示。
  @State isCommentVisible: boolean = false; // 用来判断评论视图是否显示。
  @State currentPageNum: number = 1; // 书籍在第几页。
  readonly flipPage_zIndex = 2;
  readonly leftRightFlipPageName = '左右翻页';
  readonly upDownFlipPageName = '上下翻页';

  build() {
    Stack() {
      if (this.buttonClickedName === this.leftRightFlipPageName) {
        LeftRightPlipPage({
          isMenuViewVisible: this.isMenuViewVisible,
          isCommentVisible: this.isCommentVisible,
          currentPageNum: this.currentPageNum
        });
      } else if (this.buttonClickedName === this.upDownFlipPageName) {
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
        TopView({ isMenuViewVisible: this.isMenuViewVisible })
          .zIndex(this.flipPage_zIndex)
        BottomView({
          isMenuViewVisible: this.isMenuViewVisible,
          buttonClickedName: this.buttonClickedName,
          filledName: this.filledName,
          isVisible: this.isVisible,
          isCommentVisible: this.isCommentVisible,
        })
          .zIndex(this.flipPage_zIndex)
      }
      .height($r('app.string.pageflip_full_size'))
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick((event?: ClickEvent) => { // 弹出上下菜单视图时，由于Column中间无组件，点击事件会被下一层的LeftRightPlipPage或UpDownFlipPage或CoverFlipPage的点击事件取代。
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