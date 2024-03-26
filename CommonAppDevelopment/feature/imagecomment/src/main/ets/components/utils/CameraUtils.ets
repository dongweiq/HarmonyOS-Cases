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

import common from '@ohos.app.ability.common';
import { Constants } from '../constants/Constants';

// TODO：知识点：通过context.startAbilityForResult接口拉起相机拍照，并通过result返回照片地址
export async function cameraCapture(context: common.UIAbilityContext): Promise<string> {
  // 通过context.startAbilityForResult拉起相机
  const result: common.AbilityResult = await context.startAbilityForResult({
    action: Constants.ACTION_PICKER_CAMERA, // 拉起相机的action
    parameters: {
      'supportMultiMode': false, // 是否可以同时拍照和录像
      'callBundleName': context.abilityInfo.bundleName // 拉起相机的应用的bundleName
    }
  });
  // 相机返回的数据，如果resultCode是0，则表示返回成功
  if (result.resultCode === 0) {
    // 获取返回结果中的数据
    const param: Record<string, Object> | undefined = result.want?.parameters;
    if (param !== undefined) {
      // 通过resourceUri获取照片的本地路径
      const resourceUri: string = param[Constants.KEY_RESULT_PICKER_CAMERA] as string;
      return resourceUri;
    }
  }
  return "";
}