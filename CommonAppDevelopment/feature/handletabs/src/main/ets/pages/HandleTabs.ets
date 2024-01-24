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
 *  1. 通过@Builder自定义封装一个导航页签栏，并通过ForEach完成对Tabs组件的内容页和导航页签栏的动态渲染。
 *  2. 通过TabsController的changeIndex可实现页面的跳转，传入的index是数组中对应的索引值。
 *  3. 页签的增加通过数组的push方法，增加数组元素。
 *  4. 删除页签通过通过删除页面对应数组的索引值处的数据完成，删除后页面跳转位置根据业务逻辑要求确定跳转页面对应的索引值。
 */
import util from '@ohos.util';
import { STYLE_CONFIGURATION } from '../model/constantsData';

@Component
export struct HandleTabs {
  @State tabArray: Array<number> = [0]; // 控制页签渲染的数组
  @State focusIndex: number = 0; // Tabs组件当前显示的页签下标
  @State preIndex: number = -1; // 创建页签时的页签index
  private controller: TabsController = new TabsController(); // Tabs组件控制器，根据组件下标控制tab跳转

  // TODO：知识点：1.TabContent组件绑定自定义UIBuilder
  @Builder
  Tab(tabNumber: number) {
    Row({ space: STYLE_CONFIGURATION.TAB_BAR_GUTTER }) {
      Text("页签 " + tabNumber)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
      Image($r('app.media.ic_public_cancel_filled'))
        .width(STYLE_CONFIGURATION.ICON_SIZE)
        .height(STYLE_CONFIGURATION.ICON_SIZE)
        .onClick(() => {
          // TODO：知识点3：动态删除ForEach循环的数组变量元素，实现页签删除功能
          // 获取Tabs组件当前显示的页签中显示的数字
          let focusNumber = this.tabArray[this.focusIndex];
          // 被删除的页签是否是当前选中的页签，且是最后一个页签
          if (this.focusIndex === this.tabArray.indexOf(tabNumber) && this.focusIndex == this.tabArray.length - 1) {
            // 判断是否需要跳回到创建该页签时的页签，如果不需要直接跳转到前一个页签
            if (this.preIndex >= 0) {
              this.focusIndex = this.preIndex;
            } else {
              this.focusIndex = this.focusIndex - 1;
            }
          }
          this.tabArray.splice(this.tabArray.indexOf(tabNumber), 1);
          this.preIndex = -1;
          // 对应删除页面中的第二种情况
          if (this.tabArray.indexOf(focusNumber) >= 0) {
            this.focusIndex = this.tabArray.indexOf(focusNumber);
          }
          this.controller.changeIndex(this.focusIndex);
        })
    }
    .justifyContent(FlexAlign.Center)
    .constraintSize({ minWidth: STYLE_CONFIGURATION.TAB_CONSTRAINT_SIZE })
    .width(STYLE_CONFIGURATION.TAB_WIDTH)
    .height(STYLE_CONFIGURATION.TAB_HEIGHT)
    .borderRadius({ topLeft: STYLE_CONFIGURATION.TAB_BORDER_RADUIS, topRight: STYLE_CONFIGURATION.TAB_BORDER_RADUIS })
    .backgroundColor(this.tabArray.indexOf(tabNumber) === this.focusIndex ? $r('app.color.white') : $r('app.color.tabBarBcColor'))
    .onClick(() => {
      this.focusIndex = this.tabArray.indexOf(tabNumber);
      this.controller.changeIndex(this.focusIndex);
    })
  }

  build() {
    Column() {
      Column() {
        // 页签
        Stack() {
          Row({ space: STYLE_CONFIGURATION.ROW_GUTTER }) {
            Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
              /**
               * TODO：知识点：2.通过ForEach循环数组动态创建TabContent组件
               * 性能知识点：ForEach的第三个入参keyGenerator唯一时，动态修改ForEach时，可降低渲染开销
               * 参考文档：https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/quick-start/arkts-rendering-control-foreach.md
               */
              ForEach(this.tabArray, (item: number, index: number) => {
                TabContent() {
                  Column() {
                    if (index === 0) {
                      Column({ space: STYLE_CONFIGURATION.COLUMN_GUTTER }) {
                        Text($r('app.string.HandleTabs'))
                        Text($r('app.string.HandleTabsDesc'))
                          .fontColor($r('sys.color.ohos_fa_text_secondary'))
                      }.backgroundColor($r('app.color.white')).padding(6)
                    }

                    Text('我是页面 ' + item + " 的内容")
                      .layoutWeight(1)
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .backgroundColor($r('app.color.white'))
                  }
                }.tabBar(this.Tab(item)) // tabBar自定义UIBuilder
              }, (item: number) => item.toString() + util.generateRandomUUID())
            }
            .barMode(BarMode.Scrollable, { margin: STYLE_CONFIGURATION.TAB_BAR_MARGIN })
            .onChange((index) => {
              this.focusIndex = index;
            })
            .barHeight(30)
          }.width("100%")

          Row() {
            Image($r('app.media.ic_public_add_filled')).onClick(() => {
              // TODO：知识点4：动态添加ForEach循环的数组变量元素，实现增加页签功能
              if (this.tabArray.length === 0) {
                this.tabArray.push(0);
                this.focusIndex = this.tabArray.length - 1;
              } else {
                this.preIndex = this.focusIndex;
                this.tabArray.push(this.tabArray[this.tabArray.length - 1] + 1);
                this.focusIndex = this.tabArray.length - 1;
              }
              this.controller.changeIndex(this.focusIndex);
            })
              .width(STYLE_CONFIGURATION.ICON_SIZE)
              .height(STYLE_CONFIGURATION.ICON_SIZE)
          }
          .height(STYLE_CONFIGURATION.TAB_HEIGHT)
          .aspectRatio(1)
          .backgroundColor($r('app.color.tabBarBcColor'))
          .justifyContent(FlexAlign.Center)
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .backgroundColor($r('app.color.tabBarBcColor'))
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .height('100%')
  }
}