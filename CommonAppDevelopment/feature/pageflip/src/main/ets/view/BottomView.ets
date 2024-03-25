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
import { promptAction } from '@kit.ArkUI';

@Component
export struct BottomView {
  // Todo:知识点:@Link装饰器：父子双向同步。@Link装饰的变量与其父组件中的数据源共享相同的值。
  @Link filledName: string;
  @Link buttonClickedName: string; // 点击按钮的名称，用来判断是否已被点击。
  @Link isVisible: boolean; // 用来判断翻页方式视图是否显示。
  @Link isCommentVisible: boolean; // 用来判断评论视图是否显示。
  @Link isMenuViewVisible: boolean; // 用来判断上下菜单视图是否显示。
  readonly pageFlipBottomBlankBeight = 0.3;
  readonly pageFlipBorderWidth = 0.5;
  readonly pageFlipToastDuration = 300;
  readonly leftRightPageFlipName = '左右翻页';
  readonly upDownPageFlipName = '上下翻页';
  readonly coverPageFlipName = '覆盖翻页';
  readonly PageFlipViewList = 'flippage_view_list';
  readonly PageFlipFree = 'flippage_free';
  readonly PageFlipDiscover = 'flippage_discover';
  readonly PageFlipBrightness = 'flippage_brightness';
  readonly PageFlipSettings = 'flippage_settings';

  func1(name: string) {
    animateTo({
      duration: this.pageFlipToastDuration,
      curve: Curve.Linear,
    }, () => {
      if (this.filledName === name) {
        this.filledName = '';
        this.isCommentVisible = true;
      } else {
        promptAction.showToast({
          message: $r('app.string.pageflip_default_toast'),
          duration: this.pageFlipToastDuration
        });
        this.filledName = name;
        this.isVisible = false;
        this.isCommentVisible = false;
      }
    })
  }

  build() {
    Column() {
      Blank()
        .backgroundColor($r('app.color.pageflip_bottom_blank_backgroundcolor'))
        .width($r('app.string.pageflip_full_size'))
        .height(this.pageFlipBottomBlankBeight)

      Row() {
        Image($r('app.media.flippage_comments'))
          .width($r('app.string.pageflip_lippage_10_size'))
          .height($r('app.string.pageflip_lippage_6_size'))
          .objectFit(ImageFit.Contain)
          .padding({
            top: $r('app.integer.flippage_padding_5'),
            bottom: $r('app.integer.flippage_padding_5'),
            left: $r('app.integer.flippage_padding_10'),
            right: $r('app.integer.flippage_padding_10')
          })
        Text($r('app.string.pageflip_bottom_comment'))
          .width($r('app.string.pageflip_lippage_90_size'))
          .height($r('app.string.pageflip_lippage_6_size'))
      }
      .onClick((event?: ClickEvent) => {
        promptAction.showToast({
          message: $r('app.string.pageflip_default_toast'),
          duration: this.pageFlipToastDuration
        });
      })
      .visibility(this.isCommentVisible ? Visibility.Visible : Visibility.None)


      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Button(this.leftRightPageFlipName, { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.pageflip_button_backgroundcolor'))
          .fontColor(this.buttonClickedName === this.leftRightPageFlipName ? $r('app.color.pageflip_button_click_fontcolor') : $r('app.color.pageflip_button_fontcolor'))
          .margin({ left: $r('app.integer.flippage_margin_10') })
          .borderWidth(this.pageFlipBorderWidth)
          .onClick((event?: ClickEvent) => {
            if (this.buttonClickedName !== this.leftRightPageFlipName) {
              this.buttonClickedName = this.leftRightPageFlipName;
              this.isMenuViewVisible = false;
              this.filledName = '';
              this.isVisible = false;
            }
          })
        Button(this.upDownPageFlipName, { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.pageflip_button_backgroundcolor'))
          .fontColor(this.buttonClickedName === this.upDownPageFlipName ? $r('app.color.pageflip_button_click_fontcolor') : $r('app.color.pageflip_button_fontcolor'))
          .borderWidth(this.pageFlipBorderWidth)
          .onClick((event?: ClickEvent) => {
            if (this.buttonClickedName !== this.upDownPageFlipName) {
              this.buttonClickedName = this.upDownPageFlipName;
              this.isMenuViewVisible = false;
              this.filledName = '';
              this.isVisible = false;
            }
          })
        Button(this.coverPageFlipName, { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.pageflip_button_backgroundcolor'))
          .fontColor(this.buttonClickedName === this.coverPageFlipName ? $r('app.color.pageflip_button_click_fontcolor') : $r('app.color.pageflip_button_fontcolor'))
          .borderWidth(this.pageFlipBorderWidth)
          .margin({ right: $r('app.integer.flippage_margin_10') })
          .onClick((event?: ClickEvent) => {
            if (this.buttonClickedName !== this.coverPageFlipName) {
              this.buttonClickedName = this.coverPageFlipName;
              this.isMenuViewVisible = false;
              this.filledName = '';
              this.isVisible = false;
            }
          })
      }
      .margin({ top: $r('app.integer.flippage_margin_10'), bottom: $r('app.integer.flippage_margin_10') })
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)


      Blank()
        .backgroundColor($r('app.color.pageflip_bottom_blank_backgroundcolor'))
        .width($r('app.string.pageflip_full_size'))
        .height(this.pageFlipBottomBlankBeight)
      Row() {
        Image(this.filledName === this.PageFlipViewList ? $r('app.media.flippage_view_list_filled') : $r('app.media.flippage_view_list'))
          .width($r('app.string.pageflip_lippage_20_size'))
          .height($r('app.string.pageflip_lippage_5_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            this.func1(this.PageFlipViewList);
          })
        Image(this.filledName === this.PageFlipFree ? $r('app.media.flippage_free_filled') : $r('app.media.flippage_free'))
          .width($r('app.string.pageflip_lippage_20_size'))
          .height($r('app.string.pageflip_lippage_5_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            this.func1(this.PageFlipFree);
          })
        Image(this.filledName === this.PageFlipDiscover ? $r('app.media.flippage_discover_filled') : $r('app.media.flippage_discover'))
          .width($r('app.string.pageflip_lippage_20_size'))
          .height($r('app.string.pageflip_lippage_5_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            this.func1(this.PageFlipDiscover);
          })
        Image(this.filledName === this.PageFlipBrightness ? $r('app.media.flippage_brightness_filled') : $r('app.media.flippage_brightness'))
          .width($r('app.string.pageflip_lippage_20_size'))
          .height($r('app.string.pageflip_lippage_5_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            this.func1(this.PageFlipBrightness);
          })
        Image(this.filledName === this.PageFlipSettings ? $r('app.media.flippage_settings_filled') : $r('app.media.flippage_settings'))
          .width($r('app.string.pageflip_lippage_20_size'))
          .height($r('app.string.pageflip_lippage_5_size'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_5'))
          .onClick((event?: ClickEvent) => {
            animateTo({
              duration: this.pageFlipToastDuration,
              curve: Curve.Linear,
            }, () => {
              if (this.filledName === this.PageFlipSettings) {
                this.filledName = '';
                this.isVisible = false;
                this.isCommentVisible = true;
              } else {
                this.filledName = this.PageFlipSettings;
                this.isVisible = true;
                this.isCommentVisible = false;
              }
            })
          })
      }
    }
    .backgroundColor($r('app.color.pageflip_column_backgroundcolor'))
    .visibility(this.isMenuViewVisible ? Visibility.Visible : Visibility.None)
  }
}