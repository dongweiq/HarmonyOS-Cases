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
 1.在native侧通过调用pread系统函数实现GetTotalRawFileContent接口读取rawfile文件全部内容、GetRawFileContent接口读取rawfile文件部分内容接口
 2.导入common模块的公共组件FunctionDescription。
 3.前端调用GetTotalRawFileContent与GetRawFileContent接口获取rawfile文件内容。
 */

import testNapi from 'libnativerawfile.so';
import { FunctionDescription } from '@ohos/base';
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
    Column() {
      // 功能描述
      FunctionDescription({
        title: $r('app.string.navigation_RawFile_title'),
        content: $r('app.string.navigation_RawFile_description')
      })
      Column() {
        Row() {
          Text($r('app.string.rawFileContent'))
            .fontSize($r('app.string.rawfile_font_size_20'))
            .width('40%')
            .align(Alignment.End)
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
          Text(rawfileTotalContent)
            .width('60%')
            .fontSize($r('app.string.rawfile_font_size_14'))
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
        }
        Row() {
          Text($r('app.string.ReadStartPos'))
            .fontSize($r('app.string.rawfile_font_size_20'))
            .width('30%')
            .textAlign(TextAlign.End)
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
            .align(Alignment.End)
          TextInput({ text: this.ReadStartPos.toString() })
            .id('startPos')
            .width('40%')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: $r('app.string.rawfile_font_size_14')})
            .caretColor(Color.Blue)
            .margin($r('app.string.rawfile_margin'))
            .fontSize($r('app.string.rawfile_font_size_14'))
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.ReadStartPos = Number(value);
            })
        }
        Row() {
          Text($r('app.string.ReadLength'))
            .fontSize($r('app.string.rawfile_font_size_20'))
            .width('30%')
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
            .textAlign(TextAlign.End)
            .align(Alignment.End)
          TextInput({text: this.readLength.toString()})
            .id('contentLen')
            .width('40%')
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: $r('app.string.rawfile_font_size_14')})
            .caretColor(Color.Blue)
            .margin($r('app.string.rawfile_margin'))
            .fontSize($r('app.string.rawfile_font_size_14'))
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.readLength = Number(value);
            })
        }
        Row() {
          Text($r('app.string.ReadResult'))
            .fontSize($r('app.string.rawfile_font_size_20'))
            .width('40%')
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
            .textAlign(TextAlign.End)
            .align(Alignment.Start)
          Text(this.rawfileContent)
            .width('60%')
            .fontSize($r('app.string.rawfile_font_size_20'))
            .fontWeight(FontWeight.Normal).margin($r('app.string.rawfile_margin'))
            .align(Alignment.Start)
        }

        Button($r('app.string.ReadButton'))
          .onClick(()=> {
            this.rawfileContent = testNapi.getRawFileContent(getContext().resourceManager, 'rawfile.txt', this.ReadStartPos, this.readLength);
          }).margin($r('app.string.rawfile_margin'))
      }
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: $r('app.color.border_color'), radius: $r('app.string.rawfile_radius'), style: BorderStyle.Solid })
      .borderRadius($r('app.string.rawfile_borderRadius'))
      .padding($r('app.string.rawfile_padding'))
      .margin($r('app.string.rawfile_margin12'))
      .width('95%')
    }
    .height('100%')
  }
}