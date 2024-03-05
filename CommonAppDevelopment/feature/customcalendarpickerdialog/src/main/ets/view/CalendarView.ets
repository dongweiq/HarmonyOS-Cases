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

import { CustomCalendarPickerDialog } from './CustomCalendarPickerDialog';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsrouter';

/**
 * 自定义日历选择器
 * 通过Date对象获取当前年月日等具体时间数据，用于日历数据的显示
 * 通过CustomDialogController类显示自定义弹窗，自定义弹窗内容显示为自定义日历
 * 点击主页面当前时间，弹出自定义日历，可以选择日历时间，主页面的时间随之改变
 */

const ELEMENTS_MARGIN_L = 24;
const ELEMENTS_MARGIN_M = 8;

@Component
export struct CalendarView {
  private week: string[] = ['日', '一', '二', '三', '四', '五', '六']; // 设置日历周，从周日开始
  @State date: number[] = []; // 初始化用于当前日期显示的数组
  @State currentMonth: number = 1; // 当前月份
  @State currentDay: number = 1; // 当前日
  @State currentWeekDay: number = 0; // 当前星期几
  @State currentYear: number = 1; // 当前年分
  // 获取当前日期
  aboutToAppear(): void {
    let nowDate = new Date(); // 创建Date对象,设置当前日期和时间
    this.currentMonth = nowDate.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    this.currentDay = nowDate.getDate(); // 获取当前日
    this.currentYear = nowDate.getFullYear(); // 获取当前年份
    this.currentWeekDay = new Date(this.currentYear, this.currentMonth - 1, this.currentDay).getDay(); // 获取当前星期几
    this.date.push(this.currentMonth); // 存入月份信息
    this.date.push(this.currentDay); // 存入日期信息
    this.date.push(this.currentWeekDay); // 存入周信息
  }
  // TODO: 知识点：通过CustomDialogController类显示自定义弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomCalendarPickerDialog({
      date: this.date,
      currentMonth: this.currentMonth,
      currentDay: this.currentDay,
      currentWeekDay: this.currentWeekDay,
      currentYear: this.currentYear,
      cancel: this.onCancel
    }),
    alignment: DialogAlignment.Bottom, // 自定义弹窗底端对齐
    customStyle: true // 弹窗样式自定义
  })

  // 点击遮障层退出时的回调
  onCancel() {}

  build() {
    Column() {
      Column({space: ELEMENTS_MARGIN_L}) {
        // 出发地和目的地显示
        Row() {
          Text($r('app.string.departure')).fontSize($r('app.string.ohos_id_text_size_headline'))
          Image($r('app.media.train_transport_icon')).height($r('app.integer.train_image_size')).width($r('app.integer.train_image_size'))
          Text($r('app.string.destination')).fontSize($r('app.string.ohos_id_text_size_headline'))
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
        // 当前日期显示
        Row({space: ELEMENTS_MARGIN_M}) {
          Text(`${this.date[0]}月${this.date[1]}日`).fontSize($r('app.string.ohos_id_text_size_headline'))
          Text(`星期${this.week[this.date[2]]}`).fontSize($r('app.string.ohos_id_text_size_body1'))
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .onClick(() => {
          // 点击当前日期后打开自定义弹窗显示日历
          this.dialogController.open()
        })
        // 查询车票按钮显示
        Button($r('app.string.check_ticket'))
          .fontSize($r('app.string.ohos_id_text_size_headline'))
          .height($r('app.integer.check_button_height'))
          .width('100%')
          .type(ButtonType.Normal)
          .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      }
      .backgroundColor($r('app.color.ohos_id_color_background'))
      .padding($r('app.integer.card_padding'))
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    }
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .width('100%')
    .height('100%')
    .padding($r('app.string.ohos_id_corner_radius_default_m'))
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function getCalendarView(): void {
  CalendarView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
DynamicsRouter.registerRouterPage(RouterInfo.CUSTOM_CALENDAR_PICKER_DIALOG,wrapBuilder(getCalendarView));