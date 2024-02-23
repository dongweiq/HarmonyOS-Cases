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
import { FunctionDescription } from '@ohos/common';

@Preview
@Component
export struct SideBarContentView {
  @Link isShowSideBar: boolean;

  switchTabBar() {
    // TODO：知识点：本例核心，点击Button的时候通过显式动画来控制sidebar的显示与隐藏，因为这里只对this.isShowSideBar进行了变化，因此所有相关动画均需与其关联
    animateTo({ duration: SideBarAnimationViewConstants.SIDEBAR_ANIMATION_DURATION }, () => {
      this.isShowSideBar = !this.isShowSideBar;
    })
  }

  build() {
    Stack() {
      Column() {
        FunctionDescription({
          title: $r("app.string.case_name"),
          content: $r("app.string.case_description")
        })
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
        .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    }
    .width($r("app.string.full_size"))
    .alignContent(Alignment.End)
  }
}