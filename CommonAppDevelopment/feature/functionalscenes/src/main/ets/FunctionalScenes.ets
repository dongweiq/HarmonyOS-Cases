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
import { ListData } from './model/ListData';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Link listData: ListData[];
  @Consume('pageStack') pageStack: NavPathStack;
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData)

  /**
   * 瀑布流列表项组件布局
   *
   * @param listData 组件列表信息
   */
  @Builder
  MethodPoints(listData: ListData) {
    Column() {
      if (listData.isCropping) {
        Image(listData.imageSrc)
          .borderRadius(6)
          .objectFit(ImageFit.Fill)
          .width('100%')
      } else {
        Image(listData.imageSrc)
          .borderRadius(6)
          .objectFit(listData.isCropping ? ImageFit.Contain : ImageFit.Cover)
          .width('100%')
          .height(listData.imageHeight)
      }
      Text(listData.name)
        .padding({ left: 10 })
        .width('100%')
        .fontColor(Color.Black)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .height(16)
        .fontSize(16)
        .margin({ top: 10, bottom: 10 })
      Row() {
        Text($r('app.string.difficulty'))
          .padding({ left: 10 })
          .fontColor(Color.Black)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .height(16)
          .fontSize(14)
        Rating({
          rating: listData.ratingNumber,
          indicator: true
        })
          .stars(5)
      }
      .width('100%')
      .margin({ bottom: 10 })
      .justifyContent(FlexAlign.Start)
    }
    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
    .width('49%')
    .borderRadius(6)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPath({ name: listData.moduleName, param: listData.param });
    })
  }

  /**
   * 主页通过瀑布流和LazyForeach加载
   * WaterFlow+LazyForEach详细用法可参考性能范例：
   * https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/
   */
  build() {
    Column({ space: 2 }) {
      WaterFlow() {
        LazyForEach(this.dataSource, (item: ListData) => {
          FlowItem() {
            this.MethodPoints(item)
          }
        })
      }
      .padding({ left: 18, right: 18 })
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height('100%')
    }
    .backgroundColor("#F1F1F1")
  }
}