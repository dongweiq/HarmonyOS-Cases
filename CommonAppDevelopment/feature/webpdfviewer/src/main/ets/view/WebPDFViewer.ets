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

import web_webview from '@ohos.web.webview';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 实现步骤：
 * 1.创建一个Tabs容器组件，其中包含两个TabContent子组件，分别是预览本地PDF文件和预览网络PDF文件。
 * 2.在第一个TabContent子组件中创建一个Web组件，通过 resource 协议来预览本地PDF资源并通过.onProgressChange方法监听加载进度。
 * 3.在第二个TabContent子组件中创建一个Web组件，通过网络链接属性来加载并预览网络PDF资源并通过.onProgressChange方法监听加载进度。
 */

const START_VALUE: number = 0; // 指定当前进度值，初始化开始位置为0
const TOTAL_VALUE: number = 100; // 指定进度总长，进度条总长度为100
const RESOURCE_URL: string = 'resource://rawfile/sample.pdf#toolbar=0'; // 本地PDF文件，其中“#toolbar=0”屏蔽Web组件的工具栏
const REMOTE_URL: string = 'https://gitee.com/harmonyos-cases/cases/raw/master/CommonAppDevelopment/feature/webpdfviewer/src/main/resources/rawfile/sample.pdf#toolbar=0'; // 网络PDF文件路径，其中“#toolbar=0”屏蔽Web组件的工具栏

@Component
export struct WebPDFViewer {
  @State localProgressValue: number = 0; // 设置加载本地进度，进度条初始值为0
  @State isHiddenLocalProgress: Boolean = true; // 记录加载本地进度条显隐，进入页面默认加载
  @State remoteProgressValue: number = 0; // 设置加载网络进度，进度条初始值为0
  @State isHiddenRemoteProgress: Boolean = true; // 记录加载网络进度条显隐，进入页面默认加载
  @State tabsIndex: number = 0; // tabs组件选中的初始位置
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  tabsController: TabsController = new TabsController();

  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        // 预览本地PDF文件
        TabContent() {
          Column() {
            if (this.isHiddenLocalProgress) {
              Progress({ value: START_VALUE, total: TOTAL_VALUE, type: ProgressType.Linear })
                .width($r('app.string.progress_width'))
                .height($r('app.integer.progress_height'))
                .value(this.localProgressValue)
                .color(Color.Green)
            }
            // TODO：需求：可以对Web的下载、打印等按钮点击事件处理。
            // TODO: 知识点：加载本地PDF文件，通过resource协议加载本地资源文件。
            Web({ src: RESOURCE_URL, controller: this.controller })
              .onProgressChange((event) => {
                if (event) {
                  this.localProgressValue = event.newProgress;
                  if (this.localProgressValue >= TOTAL_VALUE) {
                    this.isHiddenLocalProgress = false;
                  }
                }
              })
              .domStorageAccess(true) // 设置是否开启文档对象模型存储接口（DOM Storage API）权限，默认未开启。
          }
        }
        .width($r('app.string.tab_content_width'))
        .backgroundColor(Color.White)
        .tabBar(
          SubTabBarStyle.of($r('app.string.tab_index_one_title'))
            .indicator({ color: $r('app.color.ohos_id_color_emphasize') })
        )

        // 预览网络PDF文件
        TabContent() {
          Column() {
            if (this.isHiddenRemoteProgress) {
              Progress({ value: START_VALUE, total: TOTAL_VALUE, type: ProgressType.Linear })
                .width($r('app.string.progress_width'))
                .height($r('app.integer.progress_height'))
                .value(this.remoteProgressValue)
                .color(Color.Green)
            }
            // TODO: 知识点：加载网络PDF文件，可以直接访问网络地址的方式。
            Web({
              src: REMOTE_URL,
              controller: this.controller
            })
              .onProgressChange((event) => {
                if (event) {
                  this.remoteProgressValue = event.newProgress;
                  if (this.remoteProgressValue >= TOTAL_VALUE) {
                    this.isHiddenRemoteProgress = false;
                  }
                }
              })
              .domStorageAccess(true) // 设置是否开启文档对象模型存储接口（DOM Storage API）权限，默认未开启。
          }
        }
        .width($r('app.string.tab_content_width'))
        .backgroundColor(Color.White)
        .tabBar(
          SubTabBarStyle.of($r('app.string.tab_index_two_title'))
            .indicator({ color: $r('app.color.ohos_id_color_emphasize') })
        )
      }
      .barBackgroundColor(Color.White)
      .barWidth($r('app.string.bar_width'))
      .scrollable(false)
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getWebPDFViewer(): void {
  WebPDFViewer();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.WEB_PDF_VIEWER, wrapBuilder(getWebPDFViewer));