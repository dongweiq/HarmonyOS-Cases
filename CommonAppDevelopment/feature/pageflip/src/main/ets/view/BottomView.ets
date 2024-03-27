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
import { CONFIGURATION, STRINGCONFIGURATION } from '../common/Constants';

@Component
export struct BottomView {
  // TODO:知识点:@Link装饰器：父子双向同步。@Link装饰的变量与其父组件中的数据源共享相同的值。
  @Link filledName: string;
  @Link buttonClickedName: string; // 点击按钮的名称，用来判断是否已被点击。
  @Link isVisible: boolean; // 用来判断翻页方式视图是否显示。
  @Link isCommentVisible: boolean; // 用来判断评论视图是否显示。
  @Link isMenuViewVisible: boolean; // 用来判断上下菜单视图是否显示。
  @State buttonNameList: Array<string> = [STRINGCONFIGURATION.LEFTRIGHTFLIPPAGENAME, STRINGCONFIGURATION.UPDOWNFLIPPAGENAME, STRINGCONFIGURATION.COVERFLIPPAGENAME]

  clickAnimate(name: string) {
    animateTo({
      duration: CONFIGURATION.PAGEFLIPTOASTDURATION,
      curve: Curve.Linear,
    }, () => {
      if (this.filledName === name) {
        this.filledName = '';
        this.isCommentVisible = true;
      } else {
        promptAction.showToast({
          message: $r('app.string.pageflip_default_toast'),
          duration: CONFIGURATION.PAGEFLIPTOASTDURATION
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
        .height(CONFIGURATION.PAGEFLIPBOTTOMBLANKBEIGHT)
      Row() {
        Image($r('app.media.flippage_comments'))
          .width($r('app.string.pageflip_topview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_text_height'))
          .objectFit(ImageFit.Contain)
          .padding({
            top: $r('app.integer.flippage_padding_small'),
            bottom: $r('app.integer.flippage_padding_small'),
            left: $r('app.integer.flippage_padding_middle'),
            right: $r('app.integer.flippage_padding_middle')
          })
        Text($r('app.string.pageflip_bottom_comment'))
          .width($r('app.string.pageflip_bottomview_row_text_width'))
          .height($r('app.string.pageflip_bottomview_row_text_height'))
      }
      .onClick(() => {
        promptAction.showToast({
          message: $r('app.string.pageflip_default_toast'),
          duration: CONFIGURATION.PAGEFLIPTOASTDURATION
        });
      })
      .visibility(this.isCommentVisible ? Visibility.Visible : Visibility.None)

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.buttonNameList, (item: string) => {
          Button(item, { type: ButtonType.Capsule })
            .backgroundColor($r('app.color.pageflip_button_backgroundcolor'))
            .fontColor(this.buttonClickedName === item ? $r('app.color.pageflip_button_click_fontcolor') : $r('app.color.pageflip_button_fontcolor'))
            .margin({ left: $r('app.integer.flippage_margin_small'),right: $r('app.integer.flippage_margin_small') })
            .borderWidth(CONFIGURATION.PAGEFLIPBORDERWIDTH)
            .onClick(() => {
              if (this.buttonClickedName !== item) {
                this.buttonClickedName = item;
                this.isMenuViewVisible = false;
                this.filledName = '';
                this.isVisible = false;
              }
            })
        }, (item: string) => item)
      }
      .margin({ top: $r('app.integer.flippage_margin_small'), bottom: $r('app.integer.flippage_margin_small') })
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)

      Blank()
        .backgroundColor($r('app.color.pageflip_bottom_blank_backgroundcolor'))
        .width($r('app.string.pageflip_full_size'))
        .height(CONFIGURATION.PAGEFLIPBOTTOMBLANKBEIGHT)
      Row() {
        Image(this.filledName === STRINGCONFIGURATION.PAGEFLIPVIEWLIST ? $r('app.media.flippage_view_list_filled') : $r('app.media.flippage_view_list'))
          .width($r('app.string.pageflip_bottomview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            this.clickAnimate(STRINGCONFIGURATION.PAGEFLIPVIEWLIST);
          })
        Image(this.filledName === STRINGCONFIGURATION.PAGEFLIPFREE ? $r('app.media.flippage_free_filled') : $r('app.media.flippage_free'))
          .width($r('app.string.pageflip_bottomview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            this.clickAnimate(STRINGCONFIGURATION.PAGEFLIPFREE);
          })
        Image(this.filledName === STRINGCONFIGURATION.PAGEFLIPDISCOVER ? $r('app.media.flippage_discover_filled') : $r('app.media.flippage_discover'))
          .width($r('app.string.pageflip_bottomview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            this.clickAnimate(STRINGCONFIGURATION.PAGEFLIPDISCOVER);
          })
        Image(this.filledName === STRINGCONFIGURATION.PAGEFLIPBRIGHTNESS ? $r('app.media.flippage_brightness_filled') : $r('app.media.flippage_brightness'))
          .width($r('app.string.pageflip_bottomview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            this.clickAnimate(STRINGCONFIGURATION.PAGEFLIPBRIGHTNESS);
          })
        Image(this.filledName === STRINGCONFIGURATION.PAGEFLIPSETTINGS ? $r('app.media.flippage_settings_filled') : $r('app.media.flippage_settings'))
          .width($r('app.string.pageflip_bottomview_row_image_width'))
          .height($r('app.string.pageflip_bottomview_row_image_height'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.integer.flippage_padding_small'))
          .onClick(() => {
            animateTo({
              duration: CONFIGURATION.PAGEFLIPTOASTDURATION,
              curve: Curve.Linear,
            }, () => {
              if (this.filledName === STRINGCONFIGURATION.PAGEFLIPSETTINGS) {
                this.filledName = '';
                this.isVisible = false;
                this.isCommentVisible = true;
              } else {
                this.filledName = STRINGCONFIGURATION.PAGEFLIPSETTINGS;
                this.isVisible = true;
                this.isCommentVisible = false;
              }
            });
          })
      }
    }
    .backgroundColor($r('app.color.pageflip_column_backgroundcolor'))
    // 扩展至所有非安全区域
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .visibility(this.isMenuViewVisible ? Visibility.Visible : Visibility.None)
  }
}