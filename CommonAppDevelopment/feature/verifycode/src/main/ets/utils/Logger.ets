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

import hilog from '@ohos.hilog';

/**
 * 日志打印类
 */
export class Logger {
  static domain: number = 0x1111;
  static prefix: string = "VerifyCode"

  static debug(format: string, ...args: string[]) {
    hilog.debug(Logger.domain, Logger.prefix, format, args);
  }

  static info(format: string, ...args: string[]) {
    hilog.info(Logger.domain, Logger.prefix, format, args);
  }

  static warn(format: string, ...args: string[]) {
    hilog.warn(Logger.domain, Logger.prefix, format, args);
  }

  static error(format: string, ...args: string[]) {
    hilog.error(Logger.domain, Logger.prefix, format, args);
  }
}