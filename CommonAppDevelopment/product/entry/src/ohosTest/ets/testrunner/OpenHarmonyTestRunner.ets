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

import { abilityDelegatorRegistry, TestRunner } from '@kit.TestKit';
import { UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { resourceManager } from '@kit.LocalizationKit';
import { util } from '@kit.ArkTS';

let abilityDelegator: abilityDelegatorRegistry.AbilityDelegator;
let abilityDelegatorArguments: abilityDelegatorRegistry.AbilityDelegatorArgs;
const JSON_PATH: string = 'mock/mock-config.json';
const TAG: string = 'testTag';

async function onAbilityCreateCallback(data: UIAbility): Promise<void> {
  hilog.info(0x0000, TAG, 'onAbilityCreateCallback, data: ${}', JSON.stringify(data));
}

async function addAbilityMonitorCallback(err: BusinessError): Promise<void> {
  hilog.info(0x0000, TAG, 'addAbilityMonitorCallback : %{public}s', JSON.stringify(err) ?? '');
}

export default class OpenHarmonyTestRunner implements TestRunner {
  constructor() {
  }

  onPrepare(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'OpenHarmonyTestRunner OnPrepare');
  }

  async onRun(): Promise<void> {
    hilog.info(0x0000, TAG, '%{public}s', 'OpenHarmonyTestRunner onRun run');
    abilityDelegatorArguments = abilityDelegatorRegistry.getArguments()
    abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator()
    const moduleName = abilityDelegatorArguments.parameters['-m'];
    const context = abilityDelegator.getAppContext().getApplicationContext().createModuleContext(moduleName);
    const mResourceManager = context.resourceManager;
    await checkMock(abilityDelegator, mResourceManager);
    const bundleName = abilityDelegatorArguments.bundleName;
    const TEST_ABILITY_NAME: string = 'TestAbility';
    const lMonitor: abilityDelegatorRegistry.AbilityMonitor = {
      abilityName: TEST_ABILITY_NAME,
      onAbilityCreate: onAbilityCreateCallback,
      moduleName: moduleName
    };
    abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback)
    const want: Want = {
      bundleName: bundleName,
      abilityName: TEST_ABILITY_NAME,
      moduleName: moduleName
    };
    abilityDelegator.startAbility(want, (err: BusinessError, data: void) => {
      hilog.info(0x0000, TAG, 'startAbility : err : %{public}s', JSON.stringify(err) ?? '');
      hilog.info(0x0000, TAG, 'startAbility : data : %{public}s', JSON.stringify(data) ?? '');
    })
    hilog.info(0x0000, TAG, '%{public}s', 'OpenHarmonyTestRunner onRun end');
  }
}

async function checkMock(abilityDelegator: abilityDelegatorRegistry.AbilityDelegator, resourceManager: resourceManager.ResourceManager): Promise<void> {
  let rawFile: Uint8Array;
  try {
    rawFile = resourceManager.getRawFileContentSync(JSON_PATH);
    hilog.info(0x0000, TAG, 'MockList file exists');
    const mockStr: string = util.TextDecoder.create("utf-8", { ignoreBOM: true }).decodeWithStream(rawFile);
    const mockMap: Record<string, string> = getMockList(mockStr);
    try {
      abilityDelegator.setMockList(mockMap)
    } catch (error) {
      const code = (error as BusinessError).code;
      const message = (error as BusinessError).message;
      hilog.error(0x0000, TAG, `abilityDelegator.setMockList failed, error code: ${code}, message: ${message}.`);
    }
  } catch (error) {
    const code = (error as BusinessError).code;
    const message = (error as BusinessError).message;
    hilog.error(0x0000, TAG, `ResourceManager:callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
  }
}

function getMockList(jsonStr: string): Record<string, string> {
  const jsonObj: Record<string, Object> = JSON.parse(jsonStr);
  const map: Map<string, object> = new Map<string, object>(Object.entries(jsonObj));
  const mockList: Record<string, string> = {};
  map.forEach((value: object, key: string) => {
    const realValue: string = value['source'].toString();
    mockList[key] = realValue;
  });
  hilog.info(0x0000, TAG, '%{public}s', 'mock-json value:' + JSON.stringify(mockList) ?? '');
  return mockList;
}