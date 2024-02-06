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

/** 实现步骤
 1.在oh-package.json5中添加第三方插件class-transformer的依赖
 2.在使用第三方插件class-transformer的页面导入class-transformer库。
 3.定义要传递的类UserBookingInfo。
 4.在获取到其他页面传过来的参数后通过class-transformer的plainToClass方法转换成类对象
 5.调用类对象的方法
 */
import { UserBookingInfo } from '../components/UserBookingInfo'
import { FunctionDescription } from '@ohos/base';
// TODO: 导入第三方插件class-transformer
import { plainToClass } from "class-transformer";
import { DynamicsRouter, RouterNameConstants } from '@ohos/dynamicsRouter/Index';

@Component
export struct NavigationParameterTransferView {
  @State userName: string = '';
  @State userID: string = '';
  @State seatNo: string = "";
  private userBooking: UserBookingInfo = new UserBookingInfo('', '', '');
  @Consume('pageStack') pageStack: NavPathStack;

  getParams() {
    let bookingString: string = this.pageStack.getParamByName(RouterNameConstants.ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER)[0] as string;
    // 转化成普通对象
    let userBookingTmp: UserBookingInfo = JSON.parse(bookingString);
    // TODO：知识点：通过调用第三方插件class-transformer的plainToClass方法转换成类对象, 不进行转换直接使用userBookingTmp调用getUserInfo方法会造成crash
    this.userBooking = plainToClass(UserBookingInfo, userBookingTmp);
    this.userName = this.userBooking.userName;
    this.userID = this.userBooking.userID;
    this.seatNo = this.userBooking.seatNo;
  }

  aboutToAppear(): void {
    this.getParams();
  }

  build() {
    Column() {
      // 功能描述
      FunctionDescription({
        title: $r('app.string.navigation_transfer_title'),
        content: $r('app.string.navigation_transfer_description')
      })

      Column() {
        Row() {
          Text($r('app.string.user_name'))
            .fontSize($r('app.string.navigation_font_size_20'))
            .width('30%')
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal)
            .margin($r('app.string.navigation_margin'))
            .align(Alignment.End)
          Text(this.userName)
            .width('60%')
            .margin($r('app.string.navigation_margin'))
            .fontSize($r('app.string.navigation_font_size_14'))
        }

        Row() {
          Text($r('app.string.user_id'))
            .fontSize($r('app.string.navigation_font_size_20'))
            .width('30%')
            .fontWeight(FontWeight.Normal)
            .margin($r('app.string.navigation_margin'))
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          Text(this.userID)
            .width('60%')
            .margin($r('app.string.navigation_margin'))
            .fontSize($r('app.string.navigation_font_size_14'))
        }

        Row() {
          Text($r('app.string.user_seatNo'))
            .fontSize($r('app.string.navigation_font_size_20'))
            .width('30%')
            .fontWeight(FontWeight.Normal)
            .margin($r('app.string.navigation_margin'))
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          Text(this.seatNo)
            .width('60%')
            .margin($r('app.string.navigation_margin'))
            .fontSize($r('app.string.navigation_font_size_14'))
        }

        Row() {
          Button($r('app.string.btn_submit'))
            .onClick(() => {
              // 调用主页传过来的类对象的getUserInfo方法
              this.userBooking.getUserInfo();
            }).margin($r('app.string.navigation_margin'))
          Button($r('app.string.btn_back'))
            .onClick(() => {
              this.pageStack.pop();
            }).margin($r('app.string.navigation_margin'))
        }
      }
      .backgroundColor('#FFFFFF')
      .border({
        width: 1,
        color: $r('app.color.border_color'),
        radius: $r('app.string.navigation_radius'),
        style: BorderStyle.Solid
      })
      .borderRadius($r('app.string.navigation_margin'))
      .padding($r('app.string.navigation_padding'))
      .margin($r('app.string.navigation_margin12'))
    }
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
// 当需要接收通过navigation传递的数据时，需要给接口添加参数
@Builder
export function getNavigationParameterTransferView(param: ESObject): void {
  NavigationParameterTransferView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterNameConstants.ROUTER_NAME_NAVIGATION_PARAMETER_TRANSFER;
if (!DynamicsRouter.getBuilder(builderName)) {
  let builder: WrappedBuilder<[object]> = wrapBuilder(getNavigationParameterTransferView);
  DynamicsRouter.registerBuilder(builderName, builder);
}
