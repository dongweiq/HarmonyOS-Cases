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
import { DateModel } from './DateModel';
import { getRealTimeDate } from '../components/GetDate';

/**
 * 提供持久化数据的获取、设置、和删除操作
 * @class
 */
export class DataManager {
  /**
   * 从缓存的Preferences实例中获取键对应的值
   * @param { Context } Context - 应用上下文
   * @param { function } callback - 回调函数
   */
  static getDate(context: Context, callback: (dateModel: DateModel) => void) {
    let dateModel: DateModel = getRealTimeDate();
    try {
      // 获取Preferences实例
      // TODO: 知识点: 通过用户首选项实现数据持久化
      let promise = dataPreferences.getPreferences(context, 'date')
      promise.then((object: dataPreferences.Preferences) => {
        try {
          // 从缓存的Preferences实例中获取名为'selectedDate'键对应的值
          let getPromise = object.get('selectedDate', '')
          getPromise.then((data: dataPreferences.ValueType) => {
            let dateSting = data as string;
            if (dateSting.length > 0) {
              dateModel = JSON.parse(dateSting) as DateModel;
              callback(dateModel)
            } else {
              callback(dateModel)
            }
          }).catch((err: Error) => {
            callback(dateModel)
            console.error("LoginMessage: Failed to get value of selectedDate" + err.name + ", message = " + err.message)
          })
        } catch (err) {
          callback(dateModel)
          console.error("LoginMessage: Failed to get value of selectedDate" + err.name + ", message = " + err.message)
        }
      }).catch((err: Error) => {
        callback(dateModel)
        console.error("LoginMessage: Failed to get the preferences" + err.name + ", message = " + err.message)
      })
    } catch (err) {
      callback(dateModel)
      console.error("LoginMessage: Failed to get the preferences" + err.name + ", message = " + err.message)
    }
  }

  /**
   * 将数据写入缓存的Preferences实例中，并使数据持久化
   * @param { Context } Context - 应用上下文
   * @param { DateModel } dateModel - 日期数据类
   * @param { function } callback - 回调函数
   */
  static setDate(context: Context, dateModel: DateModel, callback: () => void) {
    try {
      // 获取Preferences实例
      let promise = dataPreferences.getPreferences(context, 'date')
      promise.then((object: dataPreferences.Preferences) => {
        try {
          // 将数据写入缓存的Preferences实例中
          let setPromise = object.put('selectedDate', JSON.stringify(dateModel))
          setPromise.then(() => {
            // 将缓存的Preferences实例中的数据异步存储到用户首选项的持久化文件中
            let flushPromise = object.flush()
            flushPromise.then(() => {
              // 创建单个AppStorage的键值对
              AppStorage.setOrCreate<DateModel>('selectedDate', dateModel)
              callback()
            }).catch((err: Error) => {
              callback()
              console.error("LoginMessage: Failed to flush" + err.name + ", message = " + err.message)
            })
          }).catch((err: Error) => {
            callback()
            console.error("LoginMessage: Failed to put selectedDate" + err.name + ", message = " + err.message)
          })
        } catch (err) {
          callback()
          console.error("LoginMessage: Failed to put selectedDate" + err.name + ", message = " + err.message)
        }
      }).catch((err: Error) => {
        callback()
        console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
      })
    } catch (err) {
      callback()
      console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
    }
  }

  /**
   * 从缓存的Preferences实例中删除名为给定Key的存储键值对，并使数据持久化
   * @param { Context } Context - 应用上下文
   * @param { function } callback - 回调函数
   */
  static deleteDate(context: Context, callback: () => void) {
    try {
      let promise = dataPreferences.getPreferences(context, 'date')
      promise.then((object: dataPreferences.Preferences) => {
        try {
          // 从缓存的Preferences实例中删除名为selectedDate的存储键值对
          let deletePromise = object.delete('selectedDate')
          deletePromise.then(() => {
            // 将缓存的Preferences实例中的数据异步存储到用户首选项的持久化文件中
            let flushPromise = object.flush()
            flushPromise.then(() => {
              // 创建单个AppStorage的键值对，key为selectedDate的键值对置为undefined
              AppStorage.setOrCreate<DateModel>('selectedDate', undefined)
              callback()
            }).catch((err: Error) => {
              console.error("LoginMessage: Failed to flush" + err.name + ", message = " + err.message)
            })
          }).catch((err: Error) => {
            console.error("LoginMessage: Failed to delete selectedDate" + err.name + ", message = " + err.message)
          })
        } catch (err) {
          console.error("LoginMessage: Failed to delete selectedDate" + err.name + ", message = " + err.message)
        }
      }).catch((err: Error) => {
        console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
      })
    } catch (err) {
      console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
    }
  }
}
