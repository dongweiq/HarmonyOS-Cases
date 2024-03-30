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

import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter';
import { SceneModuleInfo } from './model/SceneModuleInfo';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';
import { TAB_DATA, TabDataModel } from './model/TabsData';
import { emitter } from '@kit.BasicServicesKit';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Link listData: SceneModuleInfo[];
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);
  @State tabsIndex: number = 0;
  tabsController: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string | undefined) {
    Row() {
      Text(name)
        .fontSize($r('app.string.ohos_id_text_size_body1'))
        .fontColor(Color.Black)
        .opacity(this.tabsIndex === index ? 1 : 0.8)
        .fontWeight(this.tabsIndex === index ? 600 : 400)
        .height('100%')
        .border(this.tabsIndex === index ? {
          width: { left: 0, right: 0, top: 0, bottom: $r('app.string.main_page_tab_text_underline') },
          color: { bottom: Color.Black },
          style: BorderStyle.Solid
        } :
          {
            width: 0
          })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor(Color.White)
    .height('100%')
    .align(Alignment.Center)
    .onClick(() => {
      this.tabsIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  /**
   * 主页通过瀑布流和LazyForeach加载
   * WaterFlow+LazyForEach详细用法可参考性能范例：
   * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/
   */
  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        ForEach(TAB_DATA, (tabItem: TabDataModel) => {
          TabContent() {
            WaterFlow() {
              LazyForEach(this.dataSource, (waterFlowItem: SceneModuleInfo) => {
                FlowItem() {
                  if (tabItem.navData === '全部' || tabItem.navData === waterFlowItem.category) {
                    methodPoints({ listData: waterFlowItem })
                  }
                }
              }, (waterFlowItem: SceneModuleInfo) => JSON.stringify(waterFlowItem))
            }
            .margin({ top: $r('app.string.main_page_padding2') })
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .cachedCount(1)
            .columnsTemplate('1fr 1fr')
            .columnsGap($r('app.string.main_page_water_flow_gap'))
            .width('100%')
          }
          .backgroundColor("#F1F1F1")
          .tabBar(
            SubTabBarStyle.of(tabItem.navData)
              .indicator({ color: Color.Black })
              .labelStyle({ font: { size: 14 } })
          )
        })
      }
      .barBackgroundColor(Color.White)
      .margin({ top: $r('app.string.main_page_padding2') })
      .padding({
        left: $r('app.string.main_page_padding2'),
        right: $r('app.string.main_page_padding2')
      })
      .barWidth('100%')
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
    .height('100%')
    .backgroundColor("#F1F1F1")
  }
}

/**
 * 瀑布流列表项组件布局
 *
 * @param listData 组件列表信息
 */
// TODO:知识点：
// 1.@Reusable标识自定义组件具备可复用的能力，它可以被添加到任意的自定义组件上。
// 2.复用自定义组件时避免一切可能改变自定义组件的组件树结构和可能使可复用组件中产生重新布局的操作以将组件复用的性能提升到最高。
@Reusable
@Component
struct methodPoints {
  @State listData: SceneModuleInfo = new SceneModuleInfo($r("app.media.address_exchange"), '地址交换动画', new RouterInfo('@ohos/addressexchange', 'AddressExchangeView'), '动效')

  /**
   * 组件的生命周期回调，在可复用组件从复用缓存中加入到组件树之前调用
   * @param params：组件更新时所需参数
   */
  aboutToReuse(params: Record<string, SceneModuleInfo>): void {
    this.listData = params.listData as SceneModuleInfo
  }

  build() {
    Column() {
      Image(this.listData.imageSrc)
        .borderRadius($r('app.string.main_page_list_borderRadius'))
        .objectFit(ImageFit.Contain)
        .width('100%')
      Text(this.listData.name)
        .padding({ left: $r('app.string.main_page_padding6'), right: $r('app.string.main_page_padding6') })
        .width('100%')
        .fontColor(Color.Black)
        .textAlign(TextAlign.Start)
        .maxLines(2)
        .fontSize($r('app.string.ohos_id_text_size_body1'))
        .margin({ top: $r('app.string.main_page_margin1'), bottom: $r('app.string.main_page_margin1') })
      Row() {
        Text($r('app.string.difficulty'))
          .padding({ left: $r('app.string.main_page_padding1') })
          .fontColor('#B7B9B8')
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .height($r('app.string.main_page_text_height'))
          .fontSize($r('app.string.main_page_text_font_size'))
        Rating({
          rating: this.listData.ratingNumber,
          indicator: true
        })
          .stars(5)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .linearGradient({
      angle: 180,
      colors: [['#CCDFFF', 0], ['#F3F4F7', 1]]
    })
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
    .width('49%')
    .borderRadius($r('app.string.main_page_list_borderRadius'))
    .margin({ top: $r('app.string.item_gap_half'), bottom: $r('app.string.item_gap_half') })
    .backgroundColor(Color.White)
    .onClick(() => {
      DynamicsRouter.pop();
      if (this.listData !== undefined) {
        // 点击瀑布流Item时，根据点击的模块信息，将页面放入路由栈
        DynamicsRouter.push(this.listData.routerInfo, this.listData.param);
        // 帮助功能：发送当前案例的名称
        let moduleName: string = this.listData.routerInfo.moduleName;
        const split: string[] = moduleName.split('/');
        moduleName = split[split.length-1];
        emitter.emit("topModule", {
          data: {
            moduleName: moduleName
          }
        })
      }
    })
  }
}

