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

@Component
export struct NativeRawfileDemo {
  @State ReadStartPos: number = 2;
  @State readLength: number = 5;
  @State rawfileContent:string = "";
  async aboutToAppear() {
    // TODO：知识点：通过Native暴露的接口getRawFileContent读取文件部分内容，getTotalRawFileContent接口读取文件全部内容
    this.rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', 2, 5);
    rawfileTotalContent = testNapi.getTotalRawFileContent(getContext().resourceManager, 'rawfile.txt');
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text($r('app.string.rawFileContent'))
            .fontSize(20)
            .width('40%')
            .align(Alignment.End)
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal).margin(10)
          Text(rawfileTotalContent)
            .width('60%')
            .fontSize(20)
            .fontWeight(FontWeight.Normal).margin(10)
        }
        Row() {
          Text($r('app.string.ReadStartPos'))
            .fontSize(20)
            .width('30%')
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal).margin(10)
            .align(Alignment.End)
          TextInput({ text: this.ReadStartPos.toString() })
            .id('startPos')
            .width('40%')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14, weight: 20 })
            .caretColor(Color.Blue)
            .margin(10)
            .fontSize(14)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.ReadStartPos = Number(value);
            })
        }
        Row() {
          Text($r('app.string.ReadLength'))
            .fontSize(20)
            .width('30%')
            .fontWeight(FontWeight.Normal).margin(10)
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          TextInput({text: this.readLength.toString()})
            .id('contentLen')
            .width('40%')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14})
            .caretColor(Color.Blue)
            .margin(10)
            .fontSize(14)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.readLength = Number(value);
            })
        }
        Row() {
          Text($r('app.string.ReadResult'))
            .fontSize(20)
            .width('40%')
            .fontWeight(FontWeight.Normal).margin(10)
            .textAlign(TextAlign.End)
            .align(Alignment.Start)
          Text(this.rawfileContent)
            .width('60%')
            .fontSize(20)
            .fontWeight(FontWeight.Normal).margin(10)
            .align(Alignment.Start)
        }

        Button($r('app.string.ReadButton'))
          .onClick(()=> {
            this.rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', this.ReadStartPos, this.readLength);
          }).margin(10)
      }
      .width('100%')
    }
    .height('100%')
  }
}