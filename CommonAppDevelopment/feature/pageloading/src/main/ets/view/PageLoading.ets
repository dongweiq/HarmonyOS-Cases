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

import { CommodityList } from './CommodityList';
import { LoadingHUD } from './LoadingHUD';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 实现步骤：
 * 1.创建一个Stack组件，LoadingHUD是加载页，内部的GoodsList为商品列表页。
 * 2.进入页面首先展示LoadingHUD加载页，3秒后，LoadingHUD加载页消失且出现GoodsList商品列表页。
 */

const MILLISECONDS: number = 3000; // 毫秒数

@Component
export struct PageLoading {
  @State isLoading: Boolean = true;

  aboutToAppear(): void {
    // 模拟网络请求操作，请求网络3秒后得到数据，通知组件，变更列表数据
    setTimeout(() => {
      this.isLoading = false;
    }, MILLISECONDS);
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 加载页-HUD全称Heads-Up Display（抬头显示）
        LoadingHUD();
      } else {
        // 商品页
        CommodityList();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getPageLoading(): void {
  PageLoading();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
const builderName = RouterInfo.LOADING_USE_STACK[0];
if (!DynamicsRouter.getBuilder(builderName)) {
  let builder: WrappedBuilder<[object]> = wrapBuilder(getPageLoading);
  DynamicsRouter.registerBuilder(builderName, builder);
}