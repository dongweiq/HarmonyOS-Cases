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

// 功能模块结构
interface ItemInfo {
  name: string
  image: Resource
  prompt?: string
}

/**
 * 实现步骤：
 * 1. 在置顶位置使用stack组件添加两层状态栏
 * 2. 通过获取Scroll的偏移量，计算透明度，分别对状态栏的组件设置透明度来实现状态栏的显隐变化效果
 */

@Component
export struct NavigationBarChangeView {
  // Scroll的偏移量
  @State scrollOffset: number = 0;
  // 状态栏组件的透明度
  @State headOpacity: number = 0;
  // 是否在顶部的标志
  @State isTop: Boolean = true;
  // 状态栏的背景颜色
  @State titleBackgroundColor: Resource = $r('app.color.ohos_id_color_background');
  // 透明度默认值
  private opacityDefaultValue: number = 1;
  // 透明度计算基数
  private opacityComputeRadix: number = 35;
  // 内容相隔距离
  private columnSpace1: number = 10;
  // 内容相隔距离
  private columnSpace2: number = 15;
  // 垂直列表列数
  private lanesSize: number = 4;
  // 自动播放时间间隔
  private intervalValue: number = 3000;
  // 创建Scroll对象
  private scroller: Scroller = new Scroller();
  // 话题battle模块显示数据
  private listData: Resource[] = [
    $r('app.media.list_page_one'),
    $r('app.media.list_page_two'),
    $r('app.media.list_page_three')
  ];
  // 我的订单模块显示数据
  private listItemData: ItemInfo[] = [
    { name: '机票', image: $r('app.media.Air_ticket')},
    { name: '火车票', image: $r('app.media.Train_ticket')},
    { name: '专车', image: $r('app.media.special_train')},
    { name: '酒店', image: $r('app.media.Hotel')}
  ];
  // 常用功能模块显示数据
  private commonListItemData: ItemInfo[] = [
    { name: '订团体票', image: $r('app.media.group_bookings')},
    { name: '订酒店', image: $r('app.media.order_hotel')},
    { name: '常旅客卡', image: $r('app.media.passenger_card')},
    { name: '常用乘机人', image: $r('app.media.passengers')},
    { name: '微信通知', image: $r('app.media.wechat')},
    { name: '发票报销', image: $r('app.media.invoice_reimbursement')},
    { name: '飞行足迹', image: $r('app.media.flight_footprint')},
    { name: '领券', image: $r('app.media.coupon_collection')},
    { name: '出行指南', image: $r('app.media.travel_guide')},
    { name: '签证', image: $r('app.media.visa'), prompt: 'new'}
  ];

  build() {
    Stack() {
      Scroll(this.scroller) {
        Column({space: this.columnSpace2}) {
          Column() {
            Text($r('app.string.text_welcome'))
              .fontSize($r('app.integer.font_size8'))
            Text($r('app.string.text_new_user_registration'))
              .fontSize($r('app.integer.font_size2'))
              .margin({top: $r('app.integer.top_interval_value1')})
            Button({ type: ButtonType.Capsule}) {
              Text($r('app.string.text_load'))
                .fontSize($r('app.integer.font_size6'))
                .fontColor(Color.White)
            }
            .margin({top: $r('app.integer.top_interval_value2')})
            .height($r('app.integer.width_and_height_value8'))
            .width($r('app.integer.width_and_height_value11'))
          }
          .width($r('app.string.width_and_height_value12'))
          .height($r('app.string.width_and_height_value2'))
          .alignItems(HorizontalAlign.Start)
          .margin({top: $r('app.integer.top_interval_value3')})

          // "我的订单"功能区
          Column() {
            Row() {
              Text($r('app.string.text_my_order'))
                .fontColor(Color.Black)
                .fontSize($r('app.integer.font_size7'))
                .margin({left: $r('app.integer.left_interval_value2')})

              // 创建功能区标题
              this.ribbonTitle();
            }
            .width($r('app.string.width_and_height_value12'))
            .height($r('app.string.width_and_height_value7'))
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              List() {
                /**
                 * 数据量比较少的情况下推荐使用ForEach，遇到数据量比较多的场景，如列表场景、瀑布流场景等，推荐使用
                 * LazyForEach(https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md/)
                 */
                ForEach(this.listItemData, (item: ItemInfo) => {
                  ListItem() {
                    Column({space: this.columnSpace1}) {
                      Image(item.image)
                        .height($r('app.integer.width_and_height_value7'))
                        .width($r('app.integer.width_and_height_value7'))
                      Text(item.name)
                        .fontSize($r('app.integer.font_size4'))
                    }
                    .width($r('app.string.width_and_height_value13'))
                  }
                })
              }
              .alignListItem(ListItemAlign.Center)
              .listDirection(Axis.Horizontal)
            }
            .width($r('app.string.width_and_height_value12'))
            .height($r('app.string.width_and_height_value9'))
          }
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.borderRadius_value2'))
          .width($r('app.string.width_and_height_value12'))
          .height($r('app.string.width_and_height_value3'))

          // "常用功能"功能区
          Column() {
            Text($r('app.string.text_common_function'))
              .fontColor(Color.Black)
              .fontSize($r('app.integer.font_size5'))
              .margin({top: $r('app.integer.top_interval_value5'),
                       left: $r('app.integer.left_interval_value2'),
                       bottom: $r('app.integer.bottom_interval_value')})

            List({space: this.columnSpace1}) {
              /**
               * 数据量比较少的情况下推荐使用ForEach，遇到数据量比较多的场景，如列表场景、瀑布流场景等，推荐使用
               * LazyForEach(https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md/)
               */
              ForEach(this.commonListItemData, (item: ItemInfo) => {
                ListItem() {
                  Column() {
                    // 创建功能视图
                    ViewItem({item: item})
                    Text(item.name)
                      .fontSize($r('app.integer.font_size3'))
                  }
                }
              })
            }
            .edgeEffect(EdgeEffect.None)
            .lanes(this.lanesSize)
            .alignListItem(ListItemAlign.Center)
            .scrollBar(BarState.Off)
          }
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.borderRadius_value2'))
          .width($r('app.string.width_and_height_value12'))
          .height($r('app.string.width_and_height_value6'))

          // "话题battle"功能区
          Column() {
            Row() {
              Text($r('app.string.text_topic_battle'))
                .fontColor(Color.Black)
                .fontSize($r('app.integer.font_size5'))
                .margin({left: $r('app.integer.left_interval_value2')})

              // 创建功能区标题
              this.ribbonTitle();
            }
            .width($r('app.string.width_and_height_value12'))
            .height($r('app.string.width_and_height_value4'))
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              List({space: this.columnSpace2}) {
                /**
                 * 数据量比较少的情况下推荐使用ForEach，遇到数据量比较多的场景，如列表场景、瀑布流场景等，推荐使用
                 * LazyForEach(https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md/)
                 */
                ForEach(this.listData, (item: Resource) => {
                  ListItem() {
                    Row() {
                      Image(item)
                        .borderRadius($r('app.integer.borderRadius_value2'))
                    }
                  }
                })
              }
              .height($r('app.string.width_and_height_value11'))
              .margin({left: $r('app.integer.left_interval_value2')})
              .borderRadius($r('app.integer.borderRadius_value2'))
              .scrollBar(BarState.Off)
              .backgroundColor(Color.White)
              .edgeEffect(EdgeEffect.None)
              .listDirection(Axis.Horizontal)
            }
            .borderRadius($r('app.integer.borderRadius_value2'))
            .width($r('app.string.width_and_height_value12'))
            .height($r('app.string.width_and_height_value10'))
          }
          .backgroundColor(Color.White)
          .borderRadius($r('app.integer.borderRadius_value2'))
          .width($r('app.string.width_and_height_value12'))
          .height($r('app.string.width_and_height_value5'))
        }
        .width($r('app.string.width_and_height_value11'))
      }
      .width($r('app.string.width_and_height_value12'))
      .height($r('app.string.width_and_height_value12'))
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      // 高性能知识点：onScroll属于频繁回调接口，应该避免在内部进行冗余和耗时操作，例如避免打印日志
      .onScroll(() => {
        // TODO 知识点：显隐变化效果，获取Scroll偏移量，计算透明度，实现效果
        this.scrollOffset = this.scroller.currentOffset().yOffset;
        if(this.scrollOffset <= this.opacityComputeRadix) {
          this.headOpacity = this.scrollOffset / this.opacityComputeRadix;
        } else {
          this.headOpacity = this.opacityDefaultValue;
        }
      })

      // 添加置顶状态栏
      Header({headOpacity: this.headOpacity, titleBackgroundColor: $r('app.color.ohos_id_color_background'), isTop: false});
      // 添加置顶状态栏
      Header({headOpacity: this.opacityDefaultValue, titleBackgroundColor: $r('app.color.transparent_color'), isTop: true});
    }
    .width($r('app.string.width_and_height_value12'))
    .height($r('app.string.width_and_height_value12'))
    .backgroundColor($r('app.color.mine_background'))
    .alignContent(Alignment.Top)
  }

  // 创建功能区标题
  @Builder
  private ribbonTitle() {
    Row() {
      Text($r('app.string.text_full_order'))
        .fontColor(Color.Black)
        .fontSize($r('app.integer.font_size3'))
      Image($r('app.media.arrow_right_icon'))
        .height($r('app.integer.width_and_height_value1'))
        .width($r('app.integer.width_and_height_value1'))
        .margin({right: $r('app.integer.right_interval_value2')})
    }
    .width($r('app.string.width_and_height_value8'))
    .justifyContent(FlexAlign.End)
  }
}

// "常用功能"功能区视图
@Component
struct ViewItem {
  item: ItemInfo = {name: '', image: $r('app.media.visa'), prompt: 'default'};

  build() {
    Stack() {
      Image(this.item.image)
        .height($r('app.integer.width_and_height_value6'))
        .width($r('app.integer.width_and_height_value6'))
      Text(this.item.prompt)
        .fontSize($r('app.integer.font_size1'))
        .fontColor(Color.White)
        .backgroundColor(Color.Red)
        .textAlign(TextAlign.Center)
        .width($r('app.integer.width_and_height_value5'))
        .height($r('app.integer.width_and_height_value2'))
        .borderRadius({topLeft: $r('app.integer.borderRadius_value1'),
                       topRight: $r('app.integer.borderRadius_value1'),
                       bottomRight: $r('app.integer.borderRadius_value1')})
        .margin({top: $r('app.integer.top_interval_value4'), left: $r('app.integer.left_interval_value3')})
        .visibility(this.item.prompt !== undefined ? Visibility.Visible : Visibility.None)
    }
  }
}

// 置顶状态栏实现
@Component
struct  Header{
  // 状态栏组件的透明度
  @Prop headOpacity: number;
  // 状态栏的背景颜色
  @Prop titleBackgroundColor: Resource;
  // 是否在顶部的标志
  @Prop isTop: Boolean;
  // 内容相隔距离
  private columnSpace: number = 15;
  // 组件置顶时透明度
  private opacityTopValue: number = 0;
  // 组件非置顶时透明度
  private opacityUnTopValue: number = 1;

  build() {
    Row() {
      Row({space: this.columnSpace}) {
        Button({ type: ButtonType.Normal}) {
          Image($r('app.media.button_setting_configuration'))
            .width($r('app.integer.width_and_height_value4'))
            .height($r('app.integer.width_and_height_value4'))
        }
        .backgroundColor($r('app.color.transparent_color'))

        Button({ type: ButtonType.Normal}) {
          Image($r('app.media.button_scan'))
            .width($r('app.integer.width_and_height_value4'))
            .height($r('app.integer.width_and_height_value4'))
        }
        .backgroundColor($r('app.color.transparent_color'))
      }
      .justifyContent(FlexAlign.Start)
      .margin({left: $r('app.integer.left_interval_value1')})
      .width($r('app.string.width_and_height_value5'))

      Text($r('app.string.text_mine'))
        .fontColor(Color.Black)
        .fontSize($r('app.integer.font_size6'))
        .opacity(this.isTop ? this.opacityTopValue : this.opacityUnTopValue)

      Row() {
        Button({ type: ButtonType.Normal}) {
          Image($r('app.media.button_customer_service_line'))
            .width($r('app.integer.width_and_height_value4'))
            .height($r('app.integer.width_and_height_value4'))
        }
        .backgroundColor($r('app.color.transparent_color'))
      }
      .justifyContent(FlexAlign.End)
      .margin({right: $r('app.integer.right_interval_value1')})
      .width($r('app.string.width_and_height_value5'))
    }
    .opacity(this.headOpacity)
    .height($r('app.integer.width_and_height_value9'))
    .width($r('app.string.width_and_height_value12'))
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.titleBackgroundColor)
  }
}