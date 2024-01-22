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
let rawfileTotalContent:string;
let rawfileContent:string;

@Component
export struct NativeRawfileDemo {
  @State startPos: number = 2;
  @State len: number = 5;
  async aboutToAppear() {
    // TODO：知识点：通过Native中暴露的接口读取rawfile内容。
    rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', 2, 5);
    rawfileTotalContent = testNapi.getTotalRawFileContent(getContext().resourceManager, 'rawfile.txt');
  }

  build() {
    Row() {
      Column() {
        Text("TotalContent: " + rawfileTotalContent)
          .fontSize(30)
          .fontWeight(FontWeight.Normal).margin(10)
          .align(Alignment.Start)
        Text("ReadStartPos: " + this.startPos.toString())
          .fontSize(30)
          .fontWeight(FontWeight.Normal).margin(10)
          .align(Alignment.Start)
        Text("ReadLen: " + this.len.toString())
          .fontSize(30)
          .fontWeight(FontWeight.Normal).margin(10)
          .align(Alignment.Start)
        Text("ReadContent: " + rawfileContent)
          .fontSize(30)
          .fontWeight(FontWeight.Normal).margin(10)
      }
      .width('100%')
    }
    .height('100%')
  }
}