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

import { ALL_CITY2, CITY_DATA } from '../model/DetailData';
import { SearchView } from '../view/SearchView';
import { CityView } from '../view/CityView';

const searchButtonText = '搜索';

/**
 * 实现步骤：
 * 通过AlphabetIndexer组件实现通过城市首字母快速定位城市的索引条导航：
 * 1. 通过AlphabetIndexer的selected属性与城市列表中List组件onScrollIndex事件绑定，
 * 2. 当用户划入或划出List显示区域时触发，通过将onScrollIndex拿到的首字母firstIndex绑定赋值给AlphabetIndexer的selected属性，
 * 从而实现List列表与AlphabetIndexer组件首字母联动吸顶展示。
 * AlphabetIndexer参考文档：
 * https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/arkui-ts/ts-container-alphabet-indexer.md/
 */
@Component
export struct CitySearch {
  // 搜索值
  @State changeValue: string = '';
  // 占位
  @State placeholder: string = getContext().resourceManager.getStringSync($r('app.string.placeholder'));
  // 搜索控制器
  controller: SearchController = new SearchController();
  // 是否展示搜索结果列表
  @State isSearchState: boolean = false;
  // 搜索结果
  @State SearchList: string[] = [];

  build() {
    Column() {
      // 搜索框
      Search({ value: this.changeValue, placeholder: this.placeholder, controller: this.controller })
        .searchButton(searchButtonText)
        .width('100%')
        .height($r('app.integer.search_height'))
        .margin({ top: $r('app.integer.search_margin_top') })
        .backgroundColor($r('app.color.search_bgc'))
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: $r('app.integer.placeholderFont_size'), weight: 400 })
        .textFont({ size: $r('app.integer.placeholderFont_size'), weight: 400 })
        .onSubmit((value: string) => {
          // 如果没有输入数据，就使用占位符作为默认数据
          if (value.length === 0) {
            value = this.placeholder;
          }
          // 将值赋值给changeValue
          this.changeValue = value;
          this.isSearchState = true;
          // 搜索
          this.searchCityList(value);
        })
        .onChange((value: string) => {
          this.changeValue = value;
          // 搜索
          this.searchCityList(value)
          if (value.length === 0) {
            // 关闭搜索列表
            this.isSearchState = false;
            // 清空数据
            this.SearchList.splice(0, this.SearchList.length);
          }
        })
        .onClick(() => {
          // 打开搜索列表
          this.isSearchState = true;
          // 清空数据
          this.SearchList.splice(0, this.SearchList.length);
        })
      // 城市列表组件
      CityView({ isSearchState: $isSearchState })

      // 搜索组件，将数据传递到搜索列表
      SearchView({ SearchList: $SearchList, isSearchState: $isSearchState })
        .width("100%")
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: $r('app.integer.padding_left'), right: $r('app.integer.padding_right') })
    .backgroundColor($r('app.color.bgc'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height('100%')
  }

  // 搜索城市展示逻辑
  searchCityList(value: string) {
    let cityNames: string[] = [];
    ALL_CITY2.forEach(item => {
      if (item.name === value) {
        item.city.forEach(city => {
          cityNames.push(city); // 当搜索关键字，将相关城市信息展示。例如搜索"an"：展示"安庆"，"安阳"。
        })
      }
      this.SearchList = cityNames;
      return;
    })
    CITY_DATA.forEach(item => {
      item.city.forEach(city => {
        if (city.includes(value)) {
          cityNames.push(city); // 当搜索汉字，会进行模糊搜索，将相关城市信息展示。例如搜索"长"：展示"长沙"，"长春"。
        }
      })
    })
    this.SearchList = cityNames;
  }
}
