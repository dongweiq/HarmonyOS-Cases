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
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsRouter/Index';

import { CustomDataType, MyDataSource, ListIndexPosition, COMPONENT_STYLE } from './DataType';
import { FunctionDescription } from '@ohos/base';

const TAG_LIST_LENGTH = 12; // TagList长度
const CONTENT_PER_TAG = 6; // 每个TAG对应多少个元素

@Component
export struct SecondaryLinkExample {
  @State @Watch('onIndexChange') currentTagIndex: number = 0; // 一级列表焦点索引值
  private tagLists: Array<string> = []; // 一级列表数据
  @State contentData: MyDataSource = new MyDataSource(); // 二级列表数据
  private records: Array<number> = []; // 二级列表分组count数量
  // TODO:知识点: 1.级联列表分别绑定不同的Scroller对象，通过调用Scroller对象方法实现控制列表滚动
  private classifyScroller: Scroller = new Scroller(); // 一级列表Scroller对象
  private scroller: Scroller = new Scroller(); // 二级列表Scroller对象
  private tagIndexPosition: ListIndexPosition = { start: 0, end: 0 }; // 一级列表可视区域的起始索引和终点索引
  private isClickTagList: boolean = false; // 是否点击一级列表

  /**
   * 生命周期函数
   */
  aboutToAppear(): void {
    // 构造数据
    for (let i = 0; i < TAG_LIST_LENGTH; i++) {
      this.tagLists.push(`类别${i + 1}`);
      let tempData: Array<CustomDataType> = new Array(CONTENT_PER_TAG).fill({ desc: '内容数据', tag: `类别${i + 1}` });
      this.records.push(i * CONTENT_PER_TAG);
      this.contentData.pushData(tempData);
    }
    this.records.push(CONTENT_PER_TAG * TAG_LIST_LENGTH);
  }

  /**
   * 监听一级列表获焦索引变化
   */
  onIndexChange() {
    let start = this.tagIndexPosition.start;
    let end = this.tagIndexPosition.end;
    if ((this.currentTagIndex === end || this.currentTagIndex === end - 1)) {
      let leftScrollCount: number = this.currentTagIndex + 2;
      leftScrollCount = leftScrollCount >= this.tagLists.length - 1 ? this.tagLists.length - 1 : leftScrollCount;
      /**
       * scrollToIndex(value: number, smooth?: boolean, align?: ScrollAlign)
       * 性能知识点：开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题。
       */
      this.classifyScroller.scrollToIndex(leftScrollCount, true); // 使获焦item向左滚动
    }
    if (this.currentTagIndex === start || this.currentTagIndex === start + 1) {
      let rightScrollCount: number = this.currentTagIndex - 2;
      rightScrollCount = rightScrollCount <= 0 ? 0 : rightScrollCount;
      this.classifyScroller.scrollToIndex(rightScrollCount, true); // 使获焦item向右滚动
    }
  }

  /**
   * 根据二级列表索引值获取对应一级列表索引
   *
   * @param {number} index - 二级列表索引值
   * @returns {number} 一级列表索引值
   */
  findClassIndex(index: number): number {
    let ans = 0;
    for (let i = 0; i < this.records.length; i++) {
      if (index >= this.records[i] && index < this.records[i + 1]) {
        ans = i;
        break;
      }
    }
    return ans;
  }

  /**
   * 根据一级列表索引值获取二级列表索引值
   *
   * @param {number} index - 一级列表索引值
   * @returns {number} 二级列表索引值
   */
  findItemIndex(index: number): number {
    return this.records[index];
  }

  build() {
    Column() {
      FunctionDescription({ title: $r('app.string.secondaryLink'), content: $r('app.string.secondaryLinkDesc') })

      Row() {
        // TODO:知识点: 2.一级列表绑定Scroller对象
        List({ scroller: this.classifyScroller, initialIndex: 0 }) {
          // 性能知识点：此处为横向列表，列表项确定且数量较少，使用了ForEach，在列表项多的情况下，推荐使用LazyForeEach
          ForEach(this.tagLists, (item: string, index: number) => {
            ListItem() {
              Column() {
                Text(item)
                  .width('100%')
                  .height(COMPONENT_STYLE.TAG_TEXT_HEIGHT)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.ohos_fa_text_secondary'))
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.currentTagIndex === index ? $r('sys.color.ohos_id_color_background') : $r('sys.color.ohos_id_color_component_normal')
                  )
              }
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.isClickTagList = true; // 当前点击的是一级列表
                }
              })
              .onClick(() => {
                // TODO:知识点: 3.点击一级列表后，通过一级列表索引获取二级列表索引，分别操作不同的Scroller对象使列表滚动到指定位置
                this.currentTagIndex = index;
                let itemIndex = this.findItemIndex(index);
                this.scroller.scrollToIndex(itemIndex, true);
              })
            }
          })
        }
        .onScrollIndex((start: number, end: number) => {
          this.tagIndexPosition = { start, end };
        })
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .height('100%')
        .width('27%')

        // 二级列表
        List({ scroller: this.scroller, space: COMPONENT_STYLE.ITEM_GUTTER }) {
          /*
            性能知识点：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
            当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
            文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
           */
          LazyForEach(this.contentData, (item: CustomDataType, index: number) => {
            ListItem() {
              Row({ space: COMPONENT_STYLE.ITEM_GUTTER }) {
                Text()
                  .aspectRatio(1)
                  .height('100%')
                  .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
                  .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
                Column({ space: COMPONENT_STYLE.SUB_ITEM_GUTTER }) {
                  Text(item.desc + index)
                  Text(item.tag)
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('app.color.contentTextFontColor'))
                  Text()
                    .height(COMPONENT_STYLE.SUB_ITEM_TEXT_HEIGHT)
                    .width(COMPONENT_STYLE.SUB_ITEM_TEXT_WIDTH_TITLE)
                    .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
                  Text()
                    .height(COMPONENT_STYLE.SUB_ITEM_TEXT_HEIGHT)
                    .width(COMPONENT_STYLE.SUB_ITEM_TEXT_WIDTH_BODY)
                    .backgroundColor($r('sys.color.ohos_id_color_component_normal'))

                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceEvenly)
                .height('100%')
              }.backgroundColor($r('app.color.white'))
              .height(COMPONENT_STYLE.SUB_ITEM_HEIGHT)
            }
            .padding({
              left: $r('sys.float.ohos_id_card_margin_start'),
              right: $r('sys.float.ohos_id_card_margin_end'),
            })
          })

          ListItem() {
            Column() {
              Text($r('app.string.nomore')).fontColor($r('sys.color.ohos_fa_text_secondary'))
              Row()
                .width('100%')
                .layoutWeight(1)
                .constraintSize({ maxHeight: COMPONENT_STYLE.BOTTOM_TOAST_TEXT_MAX_HEIGHT })
            }
          }.width('100%').margin({ top: $r('sys.float.ohos_id_card_margin_middle') })
        }
        .scrollBar(BarState.Off)
        .listDirection(Axis.Vertical) // 列表排列方向水平
        .edgeEffect(EdgeEffect.None) // 不支持滑动效果
        .flexShrink(1)
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.ohos_id_color_list_separator'),
          startMargin: $r('sys.float.ohos_id_card_margin_start'),
          endMargin: $r('sys.float.ohos_id_card_margin_end')
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isClickTagList = false; // 当前点击的非一级列表
          }
        })
        // 性能知识点:onScrollIndex事件在列表滚动时频繁执行，在回调中需要尽量减少耗时和冗余操作，例如减少不必要的日志打印
        .onScrollIndex((start: number) => {
          // TODO:知识点: 4.滑动二级列表触发组件滚动事件后，返回列表可视区域的第一个item对应的索引值，当前通过二级列表索引获取一级列表索引，操作一级列表Scroller对象使列表滚动到指定位置
          let currentClassIndex = this.findClassIndex(start);
          if (currentClassIndex !== this.currentTagIndex && this.isClickTagList !== true) {
            this.currentTagIndex = currentClassIndex;
            this.classifyScroller.scrollToIndex(currentClassIndex, true);
          }
        })
      }.width('100%').layoutWeight(1)
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getSecondaryLinkExample(): void {
  SecondaryLinkExample();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_SECONDARY_LINKAGE;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(getSecondaryLinkExample);
  DynamicsRouter.registerBuilder(builderName, builder);
}