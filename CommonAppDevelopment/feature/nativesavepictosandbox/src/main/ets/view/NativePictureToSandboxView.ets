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
 * 1. 调用native侧saveImageOfInternet接口，将返回的沙箱路径转换为Uri路径后绑定到Image组件
 * 2. 调用native侧saveImageOfRawfile接口，将返回的沙箱路径转换为Uri路径后绑定到Image组件
 */

import fileUri from "@ohos.file.fileuri";
import testNapi from 'libnativesavepictosandbox.so';
import { FunctionDescription } from '@ohos/base';
import { DynamicsRouter, RouterInfo } from '@ohos/dynamicsRouter/Index';

@Component
export struct NativePictureToSandboxView {
  private resMgr = getContext().resourceManager;                       // 获取js的资源对象
  private fileDir = getContext().filesDir;                             // 获取应用的文件路径
  private rawfilePicPath:string = "sandBoxTest.jpg";                   // rawfile中的图片名
  private internetPicUrl:string = "http://placekitten.com/96/140";     // 网络图片
  private internetSandBoxFileName:string = "internet_image.jpg";       // 网络图片保存到沙箱的图片名

  @State internetSandBoxPath:string = "";                              // 网络下载图片保存的沙箱路径
  @State rawfileSandBoxPath:string = "";                               // rawfile中图片保存的沙箱路径

  build() {
    Column() {
      // Native保存图片到应用沙箱功能描述
      FunctionDescription({
        title: $r('app.string.native_sandbox_title'),
        content: $r('app.string.native_sandbox_description')
      })
      // 保存网络图片到沙箱
      Column() {
        Row() {
          Column() {
            Image(this.internetSandBoxPath)
              .width($r('app.integer.sandBox_image_width'))
              .height($r('app.integer.sandBox_image_height'))
              .margin($r('app.integer.sandBox_margin'))
          }
          .width('30%')
          Column() {
            Button($r('app.string.tbn_InternetPicture'))
              .onClick(() => {
                // TODO：知识点：通过Native暴露的接口saveImageOfInternet接口获取下载的网络图片保存在沙箱中的路径
                let sandBoxPath: string = testNapi.saveImageOfInternet(this.internetPicUrl, this.fileDir, this.internetSandBoxFileName);
                if (sandBoxPath === undefined) {
                  AlertDialog.show({ message: $r('app.string.internet_file_write_fail'), alignment: DialogAlignment.Center });
                  this.internetSandBoxPath = '';
                } else {
                  // 将沙箱地址转换为url地址
                  this.internetSandBoxPath = fileUri.getUriFromPath(sandBoxPath);
                }
              }).margin($r('app.integer.sandBox_margin'))
              .align(Alignment.Start)
              .alignSelf(ItemAlign.Start)
            Text($r('app.string.txt_sandBox_path'))
              .fontWeight(FontWeight.Normal)
              .margin($r('app.integer.sandBox_margin'))
              .alignSelf(ItemAlign.Start)
              .textAlign(TextAlign.Start)
              .align(Alignment.Start)
            Text(this.internetSandBoxPath)
              .align(Alignment.Start)
              .margin($r('app.integer.sandBox_margin'))
              .fontSize($r('app.integer.sandBox_font_size_14'))
              .alignSelf(ItemAlign.Start)
          }
          .width('70%')
          .height($r('app.integer.sandBox_image_height180'))
        }
      }
      .border({ width: 1, color: $r('app.color.border_color'), radius: $r('app.integer.common_radius'), style: BorderStyle.Solid })
      .borderRadius($r('app.integer.common_radius'))
      .padding($r('app.integer.sandBox_padding12'))
      .margin($r('app.integer.sandBox_margin12'))
      .width('100%')
      // 保存Rawfile图片到沙箱
      Column() {
        Row() {
          Column() {
            Image(this.rawfileSandBoxPath)
              .width($r('app.integer.sandBox_image_width'))
              .height($r('app.integer.sandBox_image_height'))
              .margin($r('app.integer.sandBox_margin'))
          }
          .width('30%')
          Column() {
            Button($r('app.string.tbn_RawFilePicture'))
              .onClick(() => {
                // TODO：知识点：通过Native暴露的接口saveImageOfRawfile接口获取rawfile中图片保存在沙箱中的路径
                let sandBoxPath: string = testNapi.saveImageOfRawfile(this.resMgr, this.rawfilePicPath, this.fileDir);
                if (sandBoxPath === undefined) {
                  AlertDialog.show({ message: $r('app.string.rawfile_write_fail'), alignment: DialogAlignment.Center });
                  this.rawfileSandBoxPath = '';
                } else {
                  // 将沙箱地址转换为url地址
                  this.rawfileSandBoxPath = fileUri.getUriFromPath(sandBoxPath);
                }
              }).margin($r('app.integer.sandBox_margin'))
              .align(Alignment.Start)
              .alignSelf(ItemAlign.Start)
            Text($r('app.string.txt_sandBox_path'))
              .fontWeight(FontWeight.Normal)
              .margin($r('app.integer.sandBox_margin'))
              .alignSelf(ItemAlign.Start)
              .textAlign(TextAlign.Start)
              .align(Alignment.Start)
            Text(this.rawfileSandBoxPath)
              .align(Alignment.Start)
              .margin($r('app.integer.sandBox_margin'))
              .fontSize($r('app.integer.sandBox_font_size_14'))
              .alignSelf(ItemAlign.Start)
          }
          .width('70%')
          .height($r('app.integer.sandBox_image_height180'))
        }
      }
      .border({ width: 1, color: $r('app.color.border_color'), radius: $r('app.string.sandBox_radius'), style: BorderStyle.Solid })
      .borderRadius($r('app.string.sandBox_radius'))
      .padding($r('app.string.sandBox_padding'))
      .margin($r('app.string.sandBox_margin12'))
      .width('100%')
    }.padding($r('app.string.ohos_id_card_padding_start'))
    .height('100%')
  }
}

// 创建WrappedBuilder对象，动态路由跳转时构建页面
@Builder
export function pic2sandboxView(): void {
  NativePictureToSandboxView();
}

// 动态路由第一次加载当前页面时调用，创建WrappedBuilder对象，并注册到路由中
let builderName = RouterInfo.NATIVE_PROGRESS_NOTIFY[0];
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(pic2sandboxView);
  DynamicsRouter.registerBuilder(builderName, builder);
}