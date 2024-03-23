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

import dataPreferences from '@ohos.data.preferences';
import { FaultDataSource } from '../model/DataSource';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/base';

// TODO：知识点：初始化Preferences实例，用于异常信息的持久化存储以及获取持久化数据功能
let dataPreferencesManager: dataPreferences.Preferences = {} as dataPreferences.Preferences;

export class PreferencesManager {
  // 获取Preferences实例
  public static getPreferences(faultDataSource: FaultDataSource): void {
    logger.info('getPreferences start.');
    try {
      dataPreferences.getPreferences(AppStorage.get('context'), 'myStore', (err: BusinessError, val: dataPreferences.Preferences) => {
        if (err) {
          return;
        }
        dataPreferencesManager = val;
        logger.info('Succeeded in getting preferences.');
        // 获取异常信息
        PreferencesManager.getFaultMessage(faultDataSource);
        PreferencesManager.getFaultSign();
      })
    } catch (err) {
      logger.error("Failed to get preferences");
    }
  }

  /**
   * 存储数据异常信息
   * @param faultMessage 异常信息集合
   */
  public static putFaultMessage(faultMessage: Array<string>): void {
    logger.info(`putMessage start`);
    try {
      // TODO：知识点：通过 dataPreferencesManager.put方法存储数据
      dataPreferencesManager.put('faultMessage', JSON.stringify(faultMessage), async (err: BusinessError) => {
        if (err) {
          logger.error("Failed to put value of 'faultMessage'. code =" + err.code + ", message =" + err.message);
          return;
        }
        logger.info('Succeeded in putting value of faultMessage.');
        dataPreferencesManager.flush();
      })
    } catch (err) {
      const code = (err as BusinessError).code;
      const message = (err as BusinessError).message;
      logger.error("Failed to put value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }

  /**
   * 获取数据异常信息
   * @param faultMessage 异常信息集合
   */
  public static getFaultMessage(faultDataSource: FaultDataSource):void {
    logger.info(`getFaultMessage start`);
    try {
      // TODO：知识点：通过dataPreferencesManager.get方法获取异常信息数据
      const promise = dataPreferencesManager.get('faultMessage', []);
      promise.then(async (data: dataPreferences.ValueType) => {
        if (typeof data === 'string') {
          const faultData: Array<string> = JSON.parse(data);
          // 将异常数据添加到懒加载数据源中
          faultData.forEach((item: string) => {
            faultDataSource.pushData(item);
          })
          // 双向数据绑定懒加载数据源长度，更新数据源长度
          AppStorage.setOrCreate('faultDataSourceLength', faultDataSource.totalCount())
          logger.info('Succeeded in getting value of faultMessage.');
        }
      })
    } catch (err) {
      logger.error("Failed to get value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }

  /**
   * 存储数据标识
   */
  public static putFaultSign():void {
    logger.info(`putMessage start`);
    try {
      // TODO：知识点：通过 dataPreferencesManager.put方法存储数据
      dataPreferencesManager.put('faultSign', JSON.stringify(true), async (err: BusinessError) => {
        if (err) {
          logger.error("Failed to put value of 'faultSign'. code =" + err.code + ", message =" + err.message);
          return;
        }
        logger.info('Succeeded in putting value of faultSign.');
        dataPreferencesManager.flush();
      })
    } catch (err) {
      logger.error("putFaultSign Failed to put value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }

  /**
   * 获取数据异常信息
   */
  public static getFaultSign():void {
    logger.info(`getFaultMessage start`);
    let faultSign: boolean = false;
    try {
      // TODO：知识点：通过dataPreferencesManager.get方法获取异常标识
      const promise = dataPreferencesManager.get('faultSign', faultSign);
      promise.then((data: dataPreferences.ValueType) => {
        if (typeof data === 'string') {
          faultSign = JSON.parse(data);
          AppStorage.setOrCreate('faultSign', faultSign);
        }
      })
    } catch (err) {
      logger.error("getFaultSign Failed to get value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }
}