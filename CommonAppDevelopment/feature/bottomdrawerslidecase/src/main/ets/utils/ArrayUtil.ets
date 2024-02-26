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

import { logger } from '@ohos/utils/Index';

/**
 * 数组管理
 */
export default class ArrayUtil {
  /**
   * 删除数组中重复元素
   * param 数组对象
   * @returns Array
   */
  static listNoRepeatDate<T>(list: T[]) {
    if (null === list || undefined === list || list.length === 0) {
      return;
    }
    return Array.from(new Set(list));
  }

  /**
   * 判断数组不为空和未定义
   * param 数组对象Array<Object>
   * @returns boolean
   */
  static isNotNullEmpty(list: Array<Object> | undefined): boolean {
    return null !== list && undefined !== list && list.length >= 1;
  }

  /**
   * 判断数组为空或未定义
   * param 数组对象Array<Object>
   * @returns boolean
   */
  static isNullorEmpty(list: Array<Object> | undefined): boolean {
    return null === list || undefined === list || list.length === 0;
  }

  /**
   * 判断数组是否包含某个对象
   * param 数组对象Array<Object> 含有的对象Object
   * @returns boolean
   */
  static contains(array: Array<Object>, value: Object): boolean {
    try {
      for (let index = 0; index < array.length; index++) {
        const element = array[index];
        if (element === value) {
          return true;
        }
      }
    } catch (err) {
      logger.error('Failed ' + JSON.stringify(err))
      return false;
    }
    return false;
  }
}