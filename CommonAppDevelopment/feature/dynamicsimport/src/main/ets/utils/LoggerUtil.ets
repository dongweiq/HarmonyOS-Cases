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

let logger: ESObject = null;

// 输出log，展示HAR动态加载HAR的使用。
export function loggerInfo(message: String) {
  if (logger) {
    logger.info(message);
  } else {
    // 动态加载utils HAR中的模块
    import('@ohos/base').then((loggerResult: ESObject) => {
      logger = loggerResult.logger;
      logger.info(message);
    })
  }
}