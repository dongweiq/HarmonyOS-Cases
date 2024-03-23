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
import { SideBarAnimationViewConstants } from '../constants/SideBarAnimationViewConstants';
import { promptAction } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';

@Preview
@Component
export struct SideBarContentView {
  @Link isShowSideBar: boolean;
  @State sideBarBtnOffset: number = 0;
  deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE;

  switchTabBar() {
    // TODO：知识点：本例核心，点击Button的时候通过显式动画来控制sidebar的显示与隐藏，因为这里只对this.isShowSideBar进行了变化，因此所有相关动画均需与其关联
    animateTo({ duration: SideBarAnimationViewConstants.SIDEBAR_ANIMATION_DURATION, curve: Curve.Friction }, () => {
      this.isShowSideBar = !this.isShowSideBar;
      if (this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
        if (this.isShowSideBar) {
          this.sideBarBtnOffset = -1 * SideBarAnimationViewConstants.SIDEBAR_WIDTH;
        } else {
          this.sideBarBtnOffset = 0;
        }
      }
    })
  }

  @Builder
  buildChatInfo() {
    Row() {
      Image(null)
        .width($r("app.integer.headIconSize"))
        .height($r("app.integer.headIconSize"))
        .borderRadius($r("app.integer.headIconRadius"))
        .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
      Column() {
        Text($r("app.string.sender_info"))
        Text($r("app.string.case_description"))
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .padding($r("sys.float.ohos_id_card_margin_start"))
          .borderRadius($r("sys.float.ohos_id_corner_radius_default_m"))
          .constraintSize({
            maxWidth: $r("app.string.message_max_width")
          }) // TODO：知识点：这里使用了计算特性对组件的最大宽度进行了限制，以避免组件尺寸超出父组件
      }
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: $r("sys.float.ohos_id_card_margin_start"),
      })
    }
    .width($r("app.string.full_size"))
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Text($r("app.string.group_name"))
            .fontSize($r("sys.float.ohos_id_text_size_headline8"))
            .fontWeight(SideBarAnimationViewConstants.GROUP_NAME_FONT_WEIGHT)
            .margin($r("sys.float.ohos_id_card_margin_start"))
          Divider()
          Column() {
            this.buildChatInfo()
          }
          .width($r("app.string.full_size"))
          .padding({ top: $r("sys.float.ohos_id_card_margin_start") })
        }
        .alignItems(HorizontalAlign.Start)
        .width($r("app.string.full_size"))

        Blank()
        if (this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          TextInput()
            .defaultFocus(false)
            .width($r("app.string.full_size"))
        } else {
          Stack() {
            TextArea()
              .borderRadius($r("sys.float.ohos_id_corner_radius_default_m"))
              .height($r("app.integer.input_box_height"))
            Button($r("app.string.btn_send_msg"))
              .onClick(() => {
                promptAction.showToast({ message: $r("app.string.not_implement_prompt") })
              })
              .margin($r("sys.float.ohos_id_card_margin_end"))
          }
          .align(Alignment.BottomEnd)
        }
      }
      .alignItems(HorizontalAlign.End)
      .width($r("app.string.full_size"))
      .height($r("app.string.full_size"))
      .padding({ left: $r("sys.float.ohos_id_card_margin_start"), right: $r("sys.float.ohos_id_card_margin_start") })

      Image(this.isShowSideBar ? $r("sys.media.ohos_ic_public_arrow_right") : $r("sys.media.ohos_ic_public_arrow_left"))
        .autoResize(SideBarAnimationViewConstants.SIDEBAR_IS_BUTTON_AUTORESIZE)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.switchTabBar();
        })
        .height($r("app.integer.sidebar_button_height"))
        .width($r("app.integer.sidebar_button_width"))
        .borderRadius({
          topLeft: $r("app.integer.sidebar_button_radius"),
          bottomLeft: $r("app.integer.sidebar_button_radius")
        })
        .offset({ x: this.sideBarBtnOffset })
        .responseRegion({
          // TODO：知识点：在手机上，边缘较难相应事件，因此这里扩展了热区
          x: $r("app.integer.back_btn_x"),
          y: $r("app.integer.back_btn_y"),
          width: $r("app.integer.back_btn_response_width"),
          height: $r("app.integer.back_btn_response_height")
        })
        .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    }
    .width($r("app.string.full_size"))
    .alignContent(Alignment.End)
  }
}