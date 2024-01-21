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


import testNapi from 'libnativerawfile.so';

let rawfileContent:string;

@Component
export struct NativeRawfileDemo {
  @State startPos: number = 0;
  async aboutToAppear() {
    rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', 2, 5);
  }

  build() {
    Row() {
      Column() {
        Text("开始读取位置: " + this.startPos.toString())
          .fontSize(30)
          .fontWeight(FontWeight.Bold).margin(10)
          .align(Alignment.Start)
        Text("内容: " + rawfileContent)
          .fontSize(20)
          .fontWeight(FontWeight.Bold).margin(10)
      }
      .width('100%')
    }
    .height('100%')
  }
}