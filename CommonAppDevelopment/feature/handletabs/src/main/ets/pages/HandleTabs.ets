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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expreIndexss or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 实现步骤：
 *  1. 设置Tab组件的barHeight为0，隐藏组件自带的TabBar。
 *  2. 使用@Link修饰符，将自定义TabBar组件和Tab组件通过focusIndex和tabArray进行双向绑定。
 *  3. 在自定义TabBar中修改focusIndex和tabArray的值时，Tab组件根据数据变化进行对应UI变更。
 */
import util from '@ohos.util';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import { FunctionDescription } from '@ohos/base/Index';
import { STYLE_CONFIGURATION } from '../model/constantsData';
import { MenuBar } from './MenuBar';
import { TabSheets } from './TabSheetComponent';

@Component
export struct HandleTabs {
  @State tabArray: Array<number> = [0]; // 控制页签渲染的数组
  @State focusIndex: number = 0; // Tabs组件当前显示的页签下标
  private addressList: Array<number> = new Array(8).fill(0) // 快捷方式集合
  controller: TabsController = new TabsController(); // Tabs控制器

  build() {
    Column() {
      /**
       * 自定义TabBar组件
       * TODO:知识点：1.隐藏系统Tab组件的TabBar，在自定义tabBar组件中，修改focusIndex实现不同页签切换
       */
      TabSheets({ tabArray: $tabArray, focusIndex: $focusIndex, controller: this.controller })

      // 工具栏
      MenuBar()

      Divider()
        .width('100%')
        .backgroundColor($r('sys.color.ohos_id_color_subheading_separator'))

      Tabs({ barPosition: BarPosition.Start, index: this.focusIndex, controller: this.controller }) {
        /**
         * TODO：知识点：2.通过ForEach循环数组动态创建TabContent组件
         * 性能知识点：ForEach的第三个入参keyGenerator唯一时，动态修改ForEach时，可降低渲染开销
         * 参考文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-foreach-0000001820999585
         */
        ForEach(this.tabArray, (item: number, index: number) => {
          TabContent() {
            Column() {
              if (this.tabArray[index] === 0) {
                FunctionDescription({
                  title: $r('app.string.HandleTabs'),
                  content: $r('app.string.HandleTabsDesc')
                })
              } else {
                Column() {
                  Search().width('90%')
                  Grid() {
                    ForEach(this.addressList, () => {
                      GridItem() {
                        Column({ space: STYLE_CONFIGURATION.CONTENT_GUTTER_S }) {
                          Text()
                            .width(STYLE_CONFIGURATION.IMAGE_SIZE)
                            .aspectRatio(1)
                            .backgroundColor($r('app.color.third_black'))
                            .borderRadius(STYLE_CONFIGURATION.IMAGE_RADIUS)
                          Text()
                            .width(STYLE_CONFIGURATION.TEXT_WIDTH)
                            .height(STYLE_CONFIGURATION.TEXT_HEIGHT)
                            .backgroundColor($r('app.color.third_black'))
                        }
                      }
                    })
                  }
                  .columnsTemplate('1fr 1fr 1fr 1fr')
                  .rowsGap(STYLE_CONFIGURATION.CONTENT_GUTTER_M)
                  .rowsTemplate('1fr 1fr')
                  .height(STYLE_CONFIGURATION.GRID_HEIGHT)
                  .margin({ top: STYLE_CONFIGURATION.GRID_MARGIN })
                }
                .height('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
            .height('100%')
          }
        }, (item: number) => item.toString() + util.generateRandomUUID())
      }
      .scrollable(false)
      .barHeight(0) // 隐藏tab组件自带的tabbar
      .onChange((index: number) => {
        this.focusIndex = index;
      })
    }.width("100%")
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getHandleTabs(): void {
  HandleTabs();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterInfo.HANDLE_TABS[0];
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(getHandleTabs);
  DynamicsRouter.registerBuilder(builderName, builder);
}