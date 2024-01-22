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

/**
 * TabBar data type.
 *
 * @param id
 * @param title TarBar name.
 * @param selectedIcon Selected image address.
 * @param defaultIcon Default image address.
 */
export class TabBarDataType {
  id: number;
  title: ResourceStr;
  selectedIcon: ResourceStr;
  defaultIcon: ResourceStr;

  constructor(id: number, title: ResourceStr, selectedIcon: ResourceStr, defaultIcon: ResourceStr) {
    this.id = id;
    this.title = title;
    this.selectedIcon = selectedIcon;
    this.defaultIcon = defaultIcon;
  }
}