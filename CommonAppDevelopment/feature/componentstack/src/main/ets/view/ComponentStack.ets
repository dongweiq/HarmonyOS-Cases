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

import { IconList1, IconList2, IconList3 } from '../view/IconView';
import { ProductList } from '../view/ProductList';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 实现步骤：
 * 1.在设计布局时，考虑到头部组件位于底部且其他组件需在其之上层叠展示，选用Stack组件以达成这种堆叠效果，确保各组件间具有清晰的前后层级关系。
 * 2.为了实现顶部可滚动区域的内容堆叠和滚动效果，我们采用Scroll组件，确保用户可以顺畅地浏览滚动内容。
 * 3.在处理滚动过程中动态调整文本框高度及组件透明度的需求时，通过对Scroll组件的滚动事件回调函数onScroll处理，使其在滚动过程中实时监测并适时修改文本框的高度及组件透明度。
 * 4.在处理多层嵌套滚动场景时，保证正确的滚动顺序（即先滚动父组件再滚动子组件），只需在内层的Scroll组件中设置其nestedScroll属性，确保滚动行为符合预期。
 * 5.商品列表部分采用瀑布流（WaterFlow）布局容器进行设计，将商品信息动态分布并分成两列呈现，每列商品自上而下排列，使用了LazyForEach进行数据懒加载，WaterFlow布局时会根据可视区域按需创建FlowItem组件，并在FlowItem滑出可视区域外时销毁以降低内存占用。
 */

const ASPECT_RATIO: number = 1; // 图片的宽高比
const OPACITY: number = 0.6; // 字体设置透明度
const ZINDEX: number = 1; // 快截图标区域3放在最上层
const LAYOUTWEIGHT: number = 1; // 分配剩余空间

@Preview
@Component
export struct ComponentStack {
  @State searchHeight: number = 100; // 搜索框原始高度
  readonly searchHeight_raw: number = 100; // 备份搜索框初始高度
  @State marginTop: number = 200; // 快截图标区域2 顶部偏移量
  @State Opacity2: number = 1; // 快截图标区域2 透明度
  @State ratio: number = 1; // 快截图标区域2 缩小比例
  @State Height2: number = 100; // 快截图标区域2 高度
  readonly Height2_raw: number = 100; // 快截图标区域2 备份高度
  @State isChange: boolean = false; // 改变快截图标区域1的组件
  @State Opacity: number = 1; // 快截图标区域1的透明度
  @State marginSpace: number = 25; // 快截图标区域3 左右之间间隔
  readonly maxMarginSpace: number = 25; // IconList3默认最大间距
  readonly minmarginSpace: number = 12; // IconList3默认最小间距
  readonly IconList1_raw: number = 100; // 计算IconList1的透明度
  readonly IconList2_raw: number = 120; // 计算IconList2的透明度
  readonly IconList3_raw: number = 140; // 计算IconList3的透明度
  readonly UsedSapce: number = 110; // 已占用高度
  @StorageLink('statusHeight') statusHeight: number = 0; // 状态栏的高度
  @StorageLink('bottomHeight') bottomHeight: number = 0; // 底部安全区高度
  @StorageLink('screenHeight') screenHeight: number = 0; // 当前窗口高度
  scroller: Scroller = new Scroller();
  scroller2: Scroller = new Scroller();

  build() {
    // TODO: 知识点：堆叠容器，子组件按照顺序依次入栈，后一个子组件覆盖前一个子组件。
    Stack({ alignContent: Alignment.Top }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Image($r("app.media.user_portrait"))
          .width($r('app.integer.user_portrait_width'))
          .aspectRatio(ASPECT_RATIO)
          .borderRadius($r('app.integer.user_portrait_border_radius'))

        Image($r("app.media.stack_scan"))
          .width($r('app.integer.scan_width'))
          .aspectRatio(ASPECT_RATIO)
      }
      .padding({
        left: $r('app.integer.flex_padding_left'),
        right: $r('app.integer.flex_padding_right'),
        top: $r('app.integer.flex_padding_top')
      })
      .width('100%').height($r('app.integer.flex_height'))

      // Scroll滚动父组件
      Scroll(this.scroller) {
        Column() {
          Row() {
            Image($r('app.media.search'))
              .width($r('app.integer.search_width'))
              .aspectRatio(ASPECT_RATIO)
              .margin({ left: $r('app.integer.search_margin_left') })

            Text($r('app.string.search_title'))
              .opacity(OPACITY)
              .fontColor(Color.Black)
              .fontSize($r('app.integer.search_font_size'))
              .margin({ left: $r('app.integer.search_text_margin_left') })
          }
          .width('100%')
          .height(this.searchHeight)
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.search_border_radius'))

          // Stack堆叠组件
          Stack({ alignContent: Alignment.Top }) {
            if (this.isChange) {
              Row() {
                IconList3({ marginSpace: this.marginSpace })
              }
              .backgroundColor($r('app.color.ohos_id_color_sub_background'))
              .width('100%')
              .height($r('app.integer.icon_list_height3'))
              .opacity(this.Opacity)
              // TODO: 知识点：组件的Z序，设置组件的堆叠顺序，zIndex值越大，显示层级越高。
              .zIndex(ZINDEX)
            } else {
              Row() {
                IconList1()
              }
              .width('100%')
              .height($r('app.integer.icon_list_height1'))
              .opacity(this.Opacity)
            }
            // Scroll滚动子组件
            Scroll(this.scroller2) {
              Column() {
                Row() {
                  IconList2({ ratio: this.ratio })
                }
                .width('100%')
                .height(this.Height2)
                .opacity(this.Opacity2)

                // 商品列表组件
                ProductList()
                  .width('100%')
                  .height(px2vp(this.screenHeight - this.statusHeight - this.bottomHeight) - this.UsedSapce)
              }
              .margin({ top: this.marginTop }) // 防止遮挡IconList1
            }
            .width('100%')
            .scrollBar(BarState.Off)
            // TODO: 知识点：嵌套滚动选项。设置向前向后两个方向上的嵌套滚动模式，实现与父组件的滚动联动。
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST, // 可滚动组件往末尾端滚动时的嵌套滚动选项,父组件先滚动，父组件滚动到边缘以后自身滚动。
              scrollBackward: NestedScrollMode.SELF_FIRST // 可滚动组件往起始端滚动时的嵌套滚动选项,自身先滚动，自身滚动到边缘以后父组件滚动。
            })
            // Scroll滚动子组件函数回调
            .onScroll(() => {
              // TODO: 知识点: Scroll组件绑定onScroll事件，然后在此方法里改变该组件的margin和opacity属性值的大小实现组件移动和隐显
              // 性能知识点: onScroll属于频繁回调，不建议在onScroll做耗时和冗余操作
              let yOffset: number = this.scroller2.currentOffset().yOffset;
              this.Height2 = this.Height2_raw - yOffset * 0.5;

              // 根据yOffset的偏移量来设置IconList2的透明度，当偏移量大于等于IconList2原始高度就是透明的。
              if (1 - yOffset / this.IconList2_raw >= 0) {
                this.Opacity2 = 1 - yOffset / this.IconList2_raw; // IconList2的透明度
              } else {
                this.Opacity2 = 0;
              }
              // 巧妙利用IconList2的透明度的值Opacity2来设置IconList2的缩放。
              this.ratio = this.Opacity2;
              // 根据yOffset的偏移量来设置IconList1的透明度和IconList3的间距，当偏移量大于等于IconList1原始高度就是透明的同时IconList3的间距也是最小的。
              if (1 - yOffset / this.IconList1_raw > 0) {
                this.isChange = false;
                this.Opacity = 1 - yOffset / this.IconList1_raw; // IconList1的透明度
                this.marginSpace = this.maxMarginSpace; // IconList3默认间距
              } else {
                this.isChange = true;
                this.Opacity = (yOffset - this.IconList1_raw) / this.maxMarginSpace; // IconList1的透明度
                this.marginSpace = this.IconList3_raw - yOffset > this.minmarginSpace ?
                  (this.IconList3_raw - yOffset) : this.minmarginSpace; // IconList3的间距
              }
            })
          }
        }
        .height('100%')
        .width('100%')
        .margin({ top: $r('app.integer.margin_search_view') }) // 不遮挡搜索栏
      }
      .padding({ left: $r('app.integer.scroll_padding'), right: $r('app.integer.scroll_padding') })
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      // Scroll滚动父组件函数回调
      .onScroll(() => {
        // 获取滑动距离
        const yOffset: number = this.scroller.currentOffset().yOffset;
        // this.searchHeight 随 yOffset变化的公式。按需调整。
        this.searchHeight = this.searchHeight_raw - yOffset * 0.6;
      })
    }
    .width('100%')
    .layoutWeight(LAYOUTWEIGHT)
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .padding({ top: $r('app.integer.stack_padding_top') })
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getComponentStack(): void {
  ComponentStack();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.COMPONENT_TACK, wrapBuilder(getComponentStack));