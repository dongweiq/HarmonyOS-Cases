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
import { DynamicsRouter, RouterModel, RouterNameConstants, RouterPathConstants } from '@ohos/dynamicsRouter';
import { UserBookingInfo } from '@ohos/NavigationParameterTransferView/Index';
import { ListData } from './model/ListData';
import { WaterFlowDataSource } from './model/WaterFlowDataSource';

/**
 * 主页瀑布流列表
 */
@Component
export struct FunctionalScenes {
  @Consume('pageStack') pageStack: NavPathStack;
  private userBooking: UserBookingInfo = new UserBookingInfo('张山', '332212199507270611', '7F');
  @State strUserBooking: string = JSON.stringify(this.userBooking);
  // TODO:需求：路由栈信息，待后续封装路由管理HAR
  @State listData: ListData[] = [
    new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', RouterNameConstants.ROUTER_NAME_BAR_CHAT, 1, true, '30%', RouterPathConstants.ROUTER_PATH_BAR_CHAT),
    new ListData($r("app.media.address_exchange"), '地址交换动画', RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE, 2, true, '25%', RouterPathConstants.ROUTER_PATH_ADDRESS_EXCHANGE),
    new ListData($r("app.media.tab_bar"), '自定义TabBar页签', RouterNameConstants.ROUTER_NAME_CUSTOM_TAB_BAR, 2, true, '25%', RouterPathConstants.ROUTER_PATH_CUSTOM_TAB_BAR),
    new ListData($r("app.media.secondary_linkage"), '列表二级联动', RouterNameConstants.ROUTER_NAME_SECONDARY_LINKAGE, 1, false, '30%', RouterPathConstants.ROUTER_PATH_SECONDARY_LINKAGE),
    new ListData($r("app.media.raw_file"), '读取RawFile文件部分内容', RouterNameConstants.ROUTER_NAME_READ_RAW_FILE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_READ_RAW_FILE),
    new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION, 1, false, '40%', RouterPathConstants.ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION),
    new ListData($r("app.media.image_viewer"), '图片缩放功能实现', RouterNameConstants.ROUTER_NAME_IMAGE_VIEWER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_IMAGE_VIEWER),
    new ListData($r("app.media.todo_list"), '列表编辑', RouterNameConstants.ROUTER_NAME_PENDING_ITEMS, 1, false, '40%', RouterPathConstants.ROUTER_PATH_PENDING_ITEMS),
    new ListData($r("app.media.handle_tabs"), '增删tab页签', RouterNameConstants.ROUTER_NAME_HANDLE_TABS, 2, false, '30%', RouterPathConstants.ROUTER_PATH_HANDLE_TABS),
    new ListData($r("app.media.launch_advert"), '应用广告页', RouterNameConstants.ROUTER_NAME_LAUNCH_AVERT, 2, false, '25%', RouterPathConstants.ROUTER_PATH_LAUNCH_AVERT),
    new ListData($r("app.media.modal_window"), '全屏登录页面', RouterNameConstants.ROUTER_NAME_MODAL_WINDOW, 2, false, '40%', RouterPathConstants.ROUTER_PATH_MODAL_WINDOW),
    new ListData($r("app.media.slide_to_hide_and_displace"), '滑动页面改变顶部个人信息栏显示效果', RouterNameConstants.ROUTER_NAME_SLIDE_TO_HIDE_AND_DISPLACE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_SLIDE_TO_HIDE_AND_DISPLACE),
    new ListData($r("app.media.navigationParameterTransfer"), 'Navigation页面跳转对象传递', RouterNameConstants.ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER, 2, false, '30%', RouterPathConstants.ROUTER_PATH_NAVIGATION_PARAMETER_TRANSFER, this.strUserBooking),
    new ListData($r('app.media.aki_use_practice'), 'AKI使用实践', RouterNameConstants.ROUTER_NAME_AKI_USE_PRACTICE, 2, false, '25%', RouterPathConstants.ROUTER_PATH_AKI_USE_PRACTICE),
    new ListData($r('app.media.variable_watch'), '多层嵌套类监听', RouterNameConstants.ROUTER_NAME_VARIABLE_WATCH, 2, false, '25%', RouterPathConstants.ROUTER_PATH_VARIABLE_WATCH),
    new ListData($r('app.media.friends_book'), 'GBK文本格式解码', RouterNameConstants.ROUTER_NAME_GBK_TRANSCODING, 2, false, '25%', RouterPathConstants.ROUTER_PATH_GBK_TRANSCODING),
  ];
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(this.listData);

  aboutToAppear(): void {
    // 注册动态router
    DynamicsRouter.createRouter(this.pageStack);
  }

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
      // 点击瀑布流Item时，根据点击的模块信息，将页面放入路由栈
      let router: RouterModel = new RouterModel();
      router.path = listData.path;
      router.routerName = listData.routerName;
      router.param = listData.param;
      DynamicsRouter.push(router);
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

@Builder
export function pageMap(name: string, param: ESObject) {
  NavDestination() {
    // 根据模块名，获取WrappedBuilder对象，通过builder接口创建页面
    DynamicsRouter.getBuilder(name).builder(param);
  }
  .hideTitleBar(true)
}