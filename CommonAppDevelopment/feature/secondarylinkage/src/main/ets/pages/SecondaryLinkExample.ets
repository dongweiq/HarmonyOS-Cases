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

import { CustomDataType, MyDataSource } from './DataType';

@Entry
@Component
export struct SecondaryLinkExample {
  @State currentTagIndex: number = 0; // 一级列表焦点索引值
  private tagLists: Array<string> = []; // 一级列表数据
  @State contentData: MyDataSource = new MyDataSource(); // 二级列表数据
  private records: Array<number> = []; // 二级列表分组count数量
  // TODO:知识点: 1.级联列表分别绑定不同的Scroller对象，通过调用Scroller对象方法实现控制列表滚动
  private classifyScroller: Scroller = new Scroller(); // 一级列表Scroller对象
  private scroller: Scroller = new Scroller(); // 二级列表Scroller对象

  /**
   * 生命周期函数
   */
  aboutToAppear(): void {
    // 构造数据
    for (let i = 0; i < 9; i++) {
      this.tagLists.push(`类别${i + 1}`);
      let tempData: Array<CustomDataType> = new Array(6).fill({ desc: '内容数据', tag: `类别${i + 1}` });
      this.records.push(i * 6);
      this.contentData.pushData(tempData);
    }
    this.records.push(54);
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
    Column({ space: 12 }) {
      Column({ space: 12 }) {
        Text($r('app.string.secondaryLink')).fontSize(24)
        Text($r('app.string.secondaryLinkDesc'))
          .fontColor($r('sys.color.ohos_fa_text_secondary'))
      }.backgroundColor($r('app.color.white')).padding(6)

      Column({ space: 6 }) {
        // TODO:知识点: 2.一级列表绑定Scroller对象
        List({ space: 6, scroller: this.classifyScroller, initialIndex: 0 }) {
          // 性能注释：此处为横向列表，列表项确定且数量较少，使用了ForEach，在列表项多的情况下，推荐使用LazyForeEach
          ForEach(this.tagLists, (item: string, index: number) => {
            ListItem() {
              Column() {
                Text(item)
                  .fontSize(16)
                  .width(50)
                  .height(47)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.currentTagIndex === index ? $r('app.color.categorySelectedColor') : $r('app.color.white'))
                if (this.currentTagIndex === index) {
                  Line()
                    .width(50)
                    .height(3)
                    .strokeWidth(20)
                    .strokeLineCap(LineCapStyle.Round)
                    .backgroundColor($r('app.color.lineColor'))
                }
              }
              .onClick(() => {
                // TODO:知识点: 3.点击一级列表后，通过一级列表索引获取二级列表索引，分别操作不同的Scroller对象使列表滚动到指定位置
                this.currentTagIndex = index;
                this.classifyScroller.scrollToIndex(index);
                let itemIndex = this.findItemIndex(index);
                this.scroller.scrollToIndex(itemIndex);
              })
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .height(50)
        .width('100%')

        // 二级列表
        List({ space: 20, scroller: this.scroller }) {
          /*
            性能注释：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
            当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
            文档参考链接：https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md
           */
          LazyForEach(this.contentData, (item: CustomDataType, index: number) => {
            ListItem() {
              Row({ space: 5 }) {
                Text(item.desc + index)
                  .fontSize(30)
                  .fontColor(Color.White)
                Text(item.tag)
                  .fontSize(24)
                  .fontColor($r('app.color.contentTextFontColor'))
              }
              .width('100%')
              .height(60)
              .borderRadius(6)
              .backgroundColor($r('app.color.contentItemBcColor'))
              .justifyContent(FlexAlign.Center)
            }
          })

          ListItem() {
            Column() {
              Text($r('app.string.nomore')).fontColor($r('sys.color.ohos_fa_text_secondary'))
              Row().width('100%').layoutWeight(1).constraintSize({ maxHeight: 200 })
            }
          }.width('100%')
        }
        .scrollBar(BarState.Off)
        .listDirection(Axis.Vertical) // 列表排列方向水平
        .edgeEffect(EdgeEffect.None) // 不支持滑动效果
        .flexShrink(1)
        // 性能注释:onScrollIndex事件在列表滚动时频繁执行，在回调中需要尽量减少耗时和冗余操作，例如减少不必要的日志打印
        .onScrollIndex((start) => {
          // TODO:知识点: 4.滑动二级列表触发组件滚动事件后，返回列表可视区域的第一个item对应的索引值，当前通过二级列表索引获取一级列表索引，操作一级列表Scroller对象使列表滚动到指定位置
          let currentClassIndex = this.findClassIndex(start);
          if (currentClassIndex !== this.currentTagIndex) {
            this.currentTagIndex = currentClassIndex;
            this.classifyScroller.scrollToIndex(currentClassIndex);
          }
        })
      }.width('100%').layoutWeight(1)
    }.backgroundColor($r('app.color.pageContainerBcColor')).padding(12)
  }
}