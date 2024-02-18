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

import { DynamicsRouter } from '@ohos/dynamicsRouter/Index';
import { ListData } from '../model/ListData';
import { SearchResultDataSource } from '../model/SearchListDataSource';
import { buildRouterModel } from '@ohos/dynamicsRouter';

/**
 * 实现步骤：
 * 1.在进入首页时存储一份初始数据用于查询时筛选数据。
 * 2.通过输入框onchange接口获取输入框输入的值与ListData中name字段进行对比筛选出符合条件的数据。
 * 3.将筛选获得的数据通过LazyForeach遍历渲染，点击相应的listitem时通过统一封装的接口buildRouterModel进行跳转。
 * 4.跳转后将点击的一条数据通过PersistentStorage.persistProp持久化存储下来，保证应用退出后数据依然存在并且实现搜索历史功能。
 */
@Component
export struct SearchPage {
  @StorageLink('listData') searchListData: ListData[] | undefined = AppStorage.get('listData');
  dataSource: SearchResultDataSource = new SearchResultDataSource();
  @StorageLink('searchHistoryData') searchHistoryData: ListData[] = [];
  @State searchContext: string = '';

  aboutToAppear(): void {
    // 持久化存储保证应用退出后再进入数据还在
    PersistentStorage.persistProp('searchHistoryData', [])
  }

  /**
   * 搜索逻辑
   * @param value:输入框输入的内容
   */
  searchFunc(value: string) {
    let newListData: ListData[] = [];
    if (this.searchListData !== undefined) {
      for (let i = 0; i < this.searchListData.length; i++) {
        // 通过includes对输入的字符进行查询
        if (this.searchListData[i].name.toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchListData[i])
        }
      }
    }
    // 判断是否有输入的值
    if (value.length !== 0) {
      // 更新数据控制器数据
      this.dataSource.modifyAllData(newListData);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    } else {
      // 更新数据控制器数据
      this.dataSource.modifyAllData([]);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    }

  }

  build() {
    Column() {
      Column() {
        // TODO：知识点：使用搜索框组件，不需要自己进行封装搜索样式
        Search({ value: this.searchContext, placeholder: $r('app.string.search_placeholder') })
          .defaultFocus(true)// 默认获取焦点拉起键盘
          .backgroundColor($r('app.string.search_background_color'))
          .onChange((value: string) => {
            this.searchFunc(value)
          })
      }
      .alignSelf(ItemAlign.Start)
      .backgroundColor($r('app.string.search_background_color'))
      .borderRadius($r('app.string.main_page_top_borderRadius'))

      Text($r('app.string.search_history'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize($r('app.string.search_history_font_size1'))
        .fontColor($r('app.string.search_history_text_color'))
        .padding({ top: $r('app.string.search_history_text_padding_margin1') })
        .visibility(this.searchHistoryData.length === 0 || this.searchContext.length !== 0 ? Visibility.None : Visibility.Visible) // 没有搜索历史时隐藏
      Flex({ wrap: FlexWrap.Wrap }) {
        // 首次进入页面就需要全部加载不需要使用LazyForeach懒加载
        ForEach(this.searchHistoryData, (item: ListData) => {
          Column() {
            Text(item.name)
              .fontSize($r('app.string.search_history_font_size2'))
              .backgroundColor($r('app.string.search_list_text_color'))
              .padding($r('app.string.search_history_text_padding_margin2'))
              .borderRadius(4)
          }
          .onClick(() => {
            this.searchContext = item.name
          })
          .margin({ top: $r('app.string.search_history_text_padding_margin4') })
          .padding({ right: $r('app.string.search_history_text_padding_margin2') })
        })
      }
      .visibility(this.searchHistoryData.length === 0 || this.searchContext.length !== 0 ? Visibility.None : Visibility.Visible) // 没有搜索历史时隐藏
      .margin({ top: $r('app.string.search_history_text_padding_margin3') })

      List() {
        // TODO：知识点：使用LazyForEach加载评论列表，可以按需加载，解决一次性加载全部列表数据引起的卡顿问题，提高页面响应速度
        LazyForEach(this.dataSource, (item: ListData) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.search'))
                  .width($r('app.string.search_list_image_width'))
                Text(item.name)
                  .fontSize($r('app.string.search_history_font_size2'))
                  .margin({ left: $r('app.string.search_history_text_padding_margin2') })
              }

              Divider()
                .width('100%')
                .height(1)
                .margin({ top: $r('app.string.search_history_text_padding_margin1') })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .margin({ top: $r('app.string.search_history_text_padding_margin1') })
          .onClick(() => {
            if (this.searchHistoryData.includes(item)) {
              return;
            }
            // 更新搜索历史数据
            this.searchHistoryData.push(item);
            // 调用动态路由相关方法实现页面跳转
            buildRouterModel(item.path, item.routerName, item.param);
          })
        }, (item: ListData) => JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
    }
    .padding({ left: $r('app.string.main_page_padding'), right: $r('app.string.main_page_padding') })
    .width('100%')
    .height('100%')
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getSearchPage(): void {
  SearchPage();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = '@ohos/searchcomponent';
if (!DynamicsRouter.getBuilder(builderName)) {
  let builder: WrappedBuilder<[object]> = wrapBuilder(getSearchPage);
  DynamicsRouter.registerBuilder(builderName, builder);
}