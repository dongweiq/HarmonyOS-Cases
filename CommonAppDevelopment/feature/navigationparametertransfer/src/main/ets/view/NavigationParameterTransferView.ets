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
 2.导入class-transformer
 3.在获取到其他页面传过来的参数后通过class-transformer的plainToClass方法转换成类对象
 4.调用类对象的方法
 */
import { UserBookingInfo } from '../components/UserBookingInfo'
// TODO: 导入第三方插件class-transformer
import { plainToClass } from "class-transformer";
@Component
export struct NavigationParameterTransferView {
  @State userName: string = '';
  @State userID: string = '';
  @State seatNo: string = "";
  private userBooking: UserBookingInfo = new UserBookingInfo('', '', '');
  @Consume('pageStack') pageStack: NavPathStack;
  getParams() {
    let bookingString:string = this.pageStack.getParamByName('NavigationParameterTransfer')[0] as string;
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
      Column() {
        Row() {
          Text($r('app.string.user_name'))
            .fontSize(20)
            .width('30%')
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal)
            .margin(10)
            .align(Alignment.End)
          Text(this.userName)
            .width('60%')
            .margin(10)
            .fontSize(14)
        }
        Row() {
          Text($r('app.string.user_id'))
            .fontSize(20)
            .width('30%')
            .fontWeight(FontWeight.Normal).margin(10)
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          Text(this.userID)
            .width('60%')
            .margin(10)
            .fontSize(14)
        }
        Row() {
          Text($r('app.string.user_seatNo'))
            .fontSize(20)
            .width('30%')
            .fontWeight(FontWeight.Normal).margin(10)
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          Text(this.seatNo)
            .width('60%')
            .margin(10)
            .fontSize(14)
        }
        Row() {
          Button($r('app.string.btn_submit'))
            .onClick(() => {
              // 调用主页传过来的类对象的getUserInfo方法
              this.userBooking.getUserInfo();
            }).margin(10)
          Button($r('app.string.btn_back'))
            .onClick(() => {
              this.pageStack.pop();
            }).margin(10)
        }
      }.height('50%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}

