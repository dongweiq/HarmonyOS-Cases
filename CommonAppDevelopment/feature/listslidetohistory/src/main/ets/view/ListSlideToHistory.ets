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

import { BasicDataSource, FriendMoment } from '../model/BasicDataSource';
import { OneMoment } from './components/OneMoment';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter/Index';
import util from '@ohos.util';
import { ListConstants } from '../constants/ListConstants';

/**
 * 继承BasicDataSource的类
 */
class FriendMomentsData extends BasicDataSource<FriendMoment> {
  momentList: Array<FriendMoment> = [];

  public totalCount(): number {
    return this.momentList.length;
  }

  public getData(index: number): FriendMoment {
    // 判断组件是否已经缓存到最后一项数据了
    if (index === this.momentList.length - 1) {
      getFriendMomentFromRawfile();
    }
    return this.momentList[index];
  }

  public addData(index: number, data: FriendMoment): void {
    this.momentList.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: FriendMoment): void {
    this.momentList.push(data);
    this.notifyDataAdd(this.momentList.length - 1);
  }
}

const momentData: FriendMomentsData = new FriendMomentsData(); // 公共常亮存放LazyForEach数据实体

/** 附近的人主页面
 * 实现步骤：
 * 1.使用LazyForEach+cacheCount+@Reusable实现懒加载列表。
 * 2.创建ListScroller对象，将ListScroller对象绑定到List组件内。
 * 3.在需要记录当前位置时通过currentOffset方法存储当前偏移量historyOffset，在需要跳转时用scrollTo方法跳转。
 */
@Component
export struct ListSlideToHistory {
  @State cachedCountNumber: number = 3; // 懒加载缓存数
  @State firstIndex: number = 0; // 当前显示在屏幕上的子组件索引值，用来控制下方按钮跳转
  listScroller: ListScroller = new ListScroller(); // scroller控制器
  historyOffset: number = 0; // 上次浏览到列表距离顶端的偏移量offset
  readonly DEFAULT_OFFSET: number = 1000; // 默认跳转位置，用于第一次进入页面的跳转位置
  readonly ANIMATION_DURATION: number = 500; // 动画持续时间
  readonly SWITCH_BUTTON: number = 3; // 当前显示在屏幕上的子组件Index到达该阈值时，将跳转到历史记录按钮切换成跳转到顶部

  aboutToAppear(): void {
    // 一个函数加载10个，为保证初始页面跳转，因此加载20个列表。
    getFriendMomentFromRawfile();
    getFriendMomentFromRawfile();
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.near_message'))
          .fontSize($r('app.integer.list_history_title_fontSize'))
          .fontColor($r('app.color.title_font_color'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: $r('app.integer.list_history_title_margin_left') })
          .fontFamily($r('app.string.harmony_hei_ti'))
          .lineHeight($r('app.integer.list_history_title_line_height'))
          .layoutWeight(ListConstants.LAYOUT_WEIGHT)
      }
      .alignItems(VerticalAlign.Center)
      .height($r('app.integer.list_history_title_height'))
      .width($r('app.string.layout_100'))
      .padding({
        left: $r('app.integer.list_history_title_padding_left'),
        right: $r('app.integer.list_history_title_padding_right'),
        top: $r('app.integer.list_history_title_padding_top'),
        bottom: $r('app.integer.list_history_title_padding_bottom')
      })

      List({ space: ListConstants.LIST_SPACE, scroller: this.listScroller }) {
        // TODO：高性能知识点：列表数据较多，不需要全部渲染上屏，采用LazyForEach。
        LazyForEach(momentData, (moment: FriendMoment) => {
          ListItem() {
            OneMoment({ moment: moment })
          }
        }, (moment: FriendMoment) => moment.id)
      }
      // TODO：高性能知识点：为保证滑动流畅，采用cachedCount缓存前后节点。
      .cachedCount(this.cachedCountNumber)
      .width($r('app.string.layout_100'))
      .height($r('app.string.layout_100'))
      .listDirection(Axis.Vertical)
      .divider({
        strokeWidth: $r('app.integer.friends_page_divider_width'),
        color: $r('app.color.friends_page_divider_color'),
        startMargin: $r('app.integer.list_history_list_divider_margin'),
        endMargin: $r('app.integer.list_history_list_divider_margin')
      })
      .onScrollIndex((first: number) => {
        this.firstIndex = first;
      })

      Button(this.firstIndex < this.SWITCH_BUTTON ? $r('app.string.jump_to_history') : $r('app.string.jump_to_top'), {
        type: ButtonType.Normal,
        stateEffect: true
      })
        .fontColor($r('app.color.jump_button_font_color'))
        .height($r('app.integer.jump_button_height'))
        .borderRadius($r('app.integer.jump_button_radius'))
        .backgroundColor($r('app.color.jump_button_bgc'))
        .opacity($r('app.float.jump_button_opacity'))
        .width($r('app.integer.jump_button_width'))
        .position({ x: $r('app.string.jump_position_x'), y: $r('app.string.jump_position_y') })
        .markAnchor({ x: $r('app.string.jump_markAnchor_x') })
        .onClick(() => {
          // 当前显示的index值小于设定的SWITCH_BUTTON时，按钮为跳转到上次浏览记录，否则为跳转到顶部
          if (this.firstIndex < this.SWITCH_BUTTON) {
            this.listScroller.scrollTo({
              xOffset: 0,
              yOffset: this.historyOffset === 0 ? this.DEFAULT_OFFSET : this.historyOffset,
              animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn }
            });
          } else {
            this.historyOffset = this.listScroller.currentOffset().yOffset;
            this.listScroller.scrollTo({
              xOffset: 0,
              yOffset: 0,
              animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn }
            });
          }
        })
    }
    .height($r('app.string.layout_100'))
    .width($r('app.string.layout_100'))
  }
}

/**
 * 从Rawfile获取json数据，并通过momentData里的pushData方法放入列表数据。
 * @returns: Promise<void>
 */
async function getFriendMomentFromRawfile(): Promise<void> {
  const resourceManager = getContext().resourceManager;
  const res = await resourceManager.getRawFileContent("mockFriendMomentOneModelData.json");

  interface MyJsonModel {
    friendMoments: FriendMoment[];
  }

  const textDecoder = util.TextDecoder.create();
  const friendMomentArray = (JSON.parse(textDecoder.decodeWithStream(res)) as MyJsonModel).friendMoments;

  friendMomentArray.forEach(item => {
    // 由于获取的json的id是固定0-9，所以使用当前列表数量totalCount的十位部分加上json的id生成新的不重复id。
    item.id = Math.floor(momentData.totalCount() / 10) + item.id;
    item.text = resourceManager.getStringSync($r('app.string.jump_text_one'), parseInt(item.id) + 1) + item.text;
    momentData.pushData(item);
  })
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getListSlideToHistory(): void {
  ListSlideToHistory();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.LIST_SLIDE_TO_HISTORY, wrapBuilder(getListSlideToHistory));
