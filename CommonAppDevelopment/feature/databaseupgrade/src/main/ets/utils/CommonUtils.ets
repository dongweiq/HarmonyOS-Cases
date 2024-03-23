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
import { Constants } from '../constants/Constants';

export class CommonUtils {
  showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 1000
    });
  }

  getTableColumnTypeMapByVersion(version: number): string[][] {
    switch (version) {
      case Constants.V1:
        return Constants.V1_STUDENT_COLUMN_TYPE_MAP;
      case Constants.V2:
        return Constants.V2_STUDENT_COLUMN_TYPE_MAP;
      case Constants.V3:
        return Constants.V3_STUDENT_COLUMN_TYPE_MAP;
      default:
        throw new Error('The database version to which you need to upgrade is incorrect');
    }
  }
}

const commonUtils: CommonUtils = new CommonUtils();

export default commonUtils as CommonUtils;