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

import { BusinessError } from '@ohos.base';
import picker from '@ohos.file.picker';

/**
 * 场景描述：
 * 点击首页"+"，通过photoViewPicker.select()接口,通过传入参数PhotoSaveOptions图库对象，返回的用户选择的图片并显示在页面中，
 * 从而实现手机相册并进行图片预览和选择。
 * photoViewPicker参考文档：
 * https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/apis/js-apis-file-picker.md/#photoviewpicker
 */
@Component
export struct SelectPictures {
  @State uris: Array<string> = []; // 全局变量保存图库选择的结果uri
  @State photoCount: number = 0; // 全局变量控制选择图片的显示

  // 接口采用promise异步返回形式，传入可选参数DocumentSelectOptions对象，返回选择文件的uri数组。
  async getFileAssetsFromType() {
    const photoSelectOptions = new picker.PhotoSelectOptions(); // 创建图片-音频类型文件-预览的图库选项实例
    // 选择媒体文件类型和选择媒体文件的最大数目
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE; // 选择媒体文件类型为Image
    photoSelectOptions.maxSelectNumber = 2; // 选择媒体文件的最大数目
    // TODO：知识点：创建图库选择器实例，调用photoViewPicker.select()接口拉起图库界面进行文件选择，文件选择成功后，返回photoSelectResult结果集。
    const photoViewPicker = new picker.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions)
      .then((photoSelectResult) => { // select返回的uri权限是只读权限，需要将uri写入全局变量@State中即可进行读取文件数据操作。
        this.uris = photoSelectResult.photoUris;
        this.photoCount = this.uris.length;
      })
      .catch((err: BusinessError) => {
        console.log('Invoke photoViewPicker.select failed, code is ${err.code},message is ${err.message}');
      })
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.choice_photo'))
          .fontSize($r('app.string.ohos_id_text_size_headline'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.string.ohos_id_elements_margin_vertical_m') })
        Text($r('app.string.upload_desc'))
      }
      .backgroundColor($r('app.color.ohos_id_color_sub_background'))
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      .padding($r('app.string.ohos_id_card_padding_start'))
      .margin($r('app.string.ohos_id_card_margin_start'))

      Column() {
        Image(this.photoCount > 0 ? this.uris[0] : $r('app.media.add'))
          .objectFit(this.photoCount > 0 ? ImageFit.Contain : ImageFit.None)
          .width('50%')
          .height('30%')
          .onClick(() => {
            // TODO：知识点：通过调用getFileAssetsFromType()中的photoViewPicker.select()拉起图库界面进行图片选择。
            this.getFileAssetsFromType();
          })

        Image(this.photoCount > 1 ? this.uris[1] : '')
          .visibility(this.photoCount >1 ? Visibility.Visible : Visibility.None)
          .objectFit(this.photoCount > 1 ? ImageFit.Contain : ImageFit.None)
          .width('50%')
          .height('30%')
          .onClick(() => {
            // TODO：知识点：通过调用getFileAssetsFromType()中的photoViewPicker.select()拉起图库界面进行图片选择。
            this.getFileAssetsFromType();
          })
      }

      .margin($r('app.string.ohos_id_card_margin_start'))
    }
  }
}
