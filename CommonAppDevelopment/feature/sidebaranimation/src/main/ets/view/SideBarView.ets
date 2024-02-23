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
import { FunctionDescription } from '@ohos/common/Index';

@Preview
@Component
export struct SideBarView {
  build() {
    Column() {
      FunctionDescription({ content: $r("app.string.sidebar_message") })
    }
    .backgroundColor($r("app.color.ohos_id_color_sub_background"))
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
  }
}