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

import util from '@ohos.util';

/**
 * 表示待办事项类型。
 * @class
 */
export class ToDo {
  key: string = util.generateRandomUUID(true); // 生成随机uuid
  name: string;

  /**
   * 创建一个新的待办事项实例。
   * @param {string} name - 待办事项名称
   */
  constructor(name: string) {
    this.name = name;
  }
}