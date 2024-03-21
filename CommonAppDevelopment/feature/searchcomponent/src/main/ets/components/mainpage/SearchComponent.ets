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
import curves from '@ohos.curves';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import display from '@ohos.display';

// 持久化存储保证应用退出后再进入数据还在
PersistentStorage.persistProp('searchHistoryData', []);

/**
 * 搜索实现思路：
 * 1.在进入首页时存储一份初始数据用于查询时筛选数据。
 * 2.通过输入框onchange接口获取输入框输入的值与ListData中name字段进行对比筛选出符合条件的数据。
 * 3.将筛选获得的数据通过LazyForeach遍历渲染，点击相应的listitem时通过统一封装的接口buildRouterModel进行跳转。
 * 4.跳转后将点击的一条数据通过PersistentStorage.persistProp持久化存储下来，保证应用退出后数据依然存在并且实现搜索历史功能。
 */
/**
 * 一镜到底实现思路：
 * 1.通过bindContentCover全屏模态转场实现对搜索页面显示的控制。
 * 2.通过transition组件内转场实现搜索页面消失显示过程中的过渡效果。
 * 3.通过geometryTransition组件内隐式共享元素转场绑定两个搜索框实现传承过渡。
 * 3.在切换过程中使用animateTo显式动画配合改变搜索框大小实现转换过程中的动画和一镜到底的效果。
 */
@Component
export struct SearchComponent {
  @StorageLink('listData') searchListData: ListData[] | undefined = AppStorage.get('listData'); // 搜索原始数据
  dataSource: SearchResultDataSource = new SearchResultDataSource(); // 列表数据控制器
  @StorageLink('searchHistoryData') searchHistoryData: ListData[] = []; // 搜索历史数组
  @State searchContext: string = ''; // 搜索输入内容
  @State isSearchPageShow: boolean = false; // 搜索页面是否显式标志位
  @State geometryId: string = ''; // 组件内隐式共享元素转场id
  @State XPosition: number = 0; // 搜索框水平位移
  @State searchNewListData: ListData[] = [];
  @State avoidAreaHeight: number = 0;
  @State screenWidth: number = 0
  @StorageLink('context') UIContext: common.UIAbilityContext | undefined = AppStorage.get('context');

  aboutToAppear(): void {
    let type = window.AvoidAreaType.TYPE_SYSTEM;
    window.getLastWindow(this.UIContext, (err, data) => {
      let avoidArea = data.getWindowAvoidArea(type);
      this.avoidAreaHeight = avoidArea.topRect.height
    })
    display.getAllDisplays((err, data: Array<display.Display>) => {
      this.screenWidth = data[0].width
    });
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
          newListData.push(this.searchListData[i]);
        }
      }
    }
    // 判断是否有输入的值
    if (value.length !== 0) {
      this.searchNewListData = newListData
      // 更新数据控制器数据
      this.dataSource.modifyAllData(newListData);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    } else {
      this.searchNewListData = []
      // 更新数据控制器数据
      this.dataSource.modifyAllData([]);
      // 通知数据控制器重新加载数据
      this.dataSource.reload();
    }
  }

  /**
   * 1.搜索框进入搜索页面animateTo显式动画。
   * 2.两个搜索框同事绑定同一个geometryId。
   */
  private onSearchClicked(): void {
    this.geometryId = 'search';
    animateTo({
      duration: 100,
      // 构造插值器弹簧曲线对象，生成一条从0到1的动画曲线
      curve: curves.interpolatingSpring(0, 1, 324, 38),
      onFinish: () => {
        this.geometryId = '';
      }
    }, () => {
      this.isSearchPageShow = true;
    })
  }

  /**
   * 1.搜索框退出搜索页面animateTo显式动画。
   * 2.两个搜索框同事绑定同一个geometryId。
   */
  private onArrowClicked(): void {
    this.geometryId = 'search';
    animateTo({
      // 构造插值器弹簧曲线对象，生成一条从0到1的动画曲线
      curve: curves.interpolatingSpring(0, 1, 342, 38),
      onFinish: () => {
        this.geometryId = '';
      }
    }, () => {
      this.searchNewListData = []
      this.isSearchPageShow = false;
    })
  }

  @Builder
  searchPage() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(20)
          .onClick(() => {
            this.onArrowClicked();
          })// TODO：知识点：通过transition属性配置转场参数，在组件插入和删除时显示过渡动效
          .transition(TransitionEffect.asymmetric(
            TransitionEffect.opacity(0)
              .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 200, delay: 150 }),
            TransitionEffect.opacity(0)
              .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 200 }),
          ))
        // TODO：知识点：使用搜索框组件，不需要自己进行封装搜索样式
        Search({ value: this.searchContext, placeholder: $r('app.string.search_placeholder') })
          .defaultFocus(true)// 默认获取焦点拉起键盘
          .backgroundColor($r('app.string.search_background_color'))
          .onChange((value: string) => {
            this.searchFunc(value);
          })
          .borderRadius($r('app.string.main_page_top_borderRadius'))
          .geometryTransition(this.geometryId, { follow: true })
          .width(px2vp(this.screenWidth) - 64)
          .height(50)
          .margin({ left: 20 })
          .backgroundColor($r('app.string.search_background_color'))
          .borderRadius(8)
      }
      .alignSelf(ItemAlign.Start)

      Column() {
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
              this.searchContext = item.name;
            })
            .margin({ top: $r('app.string.search_history_text_padding_margin4') })
            .padding({ right: $r('app.string.search_history_text_padding_margin2') })
          })
        }
        .visibility(this.searchHistoryData.length === 0 || this.searchContext.length !== 0 ? Visibility.None : Visibility.Visible) // 没有搜索历史时隐藏
        .margin({ top: $r('app.string.search_history_text_padding_margin3') })
      }
      .alignItems(HorizontalAlign.Start)
      // TODO：知识点：通过transition属性配置转场参数，在组件插入和删除时显示过渡动效。非对称对称转场，第一个为出现动效有150的延迟，第二个为消失动效
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.opacity(0)
          .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 350 })
          .combine(TransitionEffect.translate({ y: 30 })),
        TransitionEffect.opacity(0)
          .animation({ curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), duration: 350 })
          .combine(TransitionEffect.translate({ y: 30 })),
      ))


      List() {
        // TODO：知识点：使用LazyForEach加载评论列表，可以按需加载，解决一次性加载全部列表数据引起的卡顿问题，提高页面响应速度
        ForEach(this.searchNewListData, (item: ListData) => {
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
            if (!this.searchHistoryData.includes(item)) {
              // 更新搜索历史数据
              this.searchHistoryData.push(item);
            }
            this.onArrowClicked();
            // 调用动态路由相关方法实现页面跳转
            DynamicsRouter.push(item.routerInfo, item.param);
            this.searchContext = ''
          })
        }, (item: ListData) => JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
      .chainAnimation(false)
      .transition({ opacity: 0 })
      .scrollBar(BarState.Off)
    }
    .transition(TransitionEffect.opacity(0))
    .backgroundColor(Color.White)
    .padding({
      left: $r('app.string.main_page_padding'),
      right: $r('app.string.main_page_padding'),
      top: px2vp(this.avoidAreaHeight)
    })
    .width('100%')
    .height('100%')
  }

  build() {
    // 顶部搜索框
    Column() {
      Search({ placeholder: $r('app.string.search_placeholder') })
        .focusOnTouch(false)
        .focusable(false)
        .enableKeyboardOnFocus(false)
        .backgroundColor('#E7E9E8')
        .width(px2vp(this.screenWidth) - 24)
        .height(50)
        .borderRadius($r('app.string.main_page_top_borderRadius'))
        .onClick(() => {
          this.onSearchClicked();
        })
        .geometryTransition(this.geometryId, { follow: true })// 搜索框转场过渡动画，cubicBezierCurve为三阶贝塞尔曲线动画
        .transition(TransitionEffect.OPACITY.animation({
          duration: 200,
          curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
        }))
        .backgroundColor('#E7E9E8')
        .borderRadius(8)
    }
    .width('100%')
    .borderRadius($r('app.string.main_page_top_borderRadius'))
    // TODO：知识点：通过bindContentCover属性为组件绑定全屏模态页面，在组件插入和删除时可通过设置转场参数ModalTransition显示过渡动效
    .bindContentCover(this.isSearchPageShow, this.searchPage(), {
      modalTransition: ModalTransition.NONE,
      onDisappear: () => {
        this.onArrowClicked();
        this.searchContext = ''
      }
    })
    .alignItems(HorizontalAlign.Center)
  }
}
