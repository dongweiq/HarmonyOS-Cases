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

// 定义一个用户类
export class UserBookingInfo {
  userName: string = '张山';                  // 姓名
  userID: string = '332045199008120045';     // 证件号
  seatNo: string = '6A';                     // 座位号
  constructor(name: string, id: string, seatNo: string) {
    this.userName = name;
    this.userID = id;
    this.seatNo = seatNo;
  }
  // 类的方法。
  getUserInfo() {
    AlertDialog.show({ message: `用户信息为 姓名: ${this.userName}, 身份证号： ${this.userID}, 座位号： ${this.seatNo}`, alignment: DialogAlignment.Center})
  }
}