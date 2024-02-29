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

export class BigFileCopyConstants {
  static readonly PROGRESS_MAX: number = 100;
  static readonly PROGRESS_MIN: number = 0;
  static readonly BUFF_SIZE: number = 4096;
  static readonly COMPONENT_SIZE: number = 200;
  static readonly ANIMATION_DURATION: number = 300;
  static readonly SANDBOX_PREFIX: string = "file://";
  static readonly TEST_FILE_NAME: string = "test.jpg";
  static readonly MIMETYPE: string = "image/jpeg";
  static readonly ACTION: string = "ohos.want.action.sendData";
}