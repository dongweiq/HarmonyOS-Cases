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

import { window } from '@kit.ArkUI';
import { logger } from '@ohos/utils';

/**
 * 窗口管理模型
 */
export default class WindowModel {
  private constructor() {
  }

  /**
   * WindowModel 单例
   */
  private static instance?: WindowModel;

  /**
   * 获取WindowModel单例实例
   * @returns {WindowModel} WindowModel
   */
  static getInstance(): WindowModel {
    if (!WindowModel.instance) {
      WindowModel.instance = new WindowModel();
    }

    return WindowModel.instance;
  }

  /**
   * 缓存的当前WindowStage实例
   */
  private windowStage?: window.WindowStage;

  /**
   * 缓存的主窗口实例
   */
  private mainWindow?: window.Window;

  /**
   * 缓存windowStage
   * @param windowStage 当前WindowStage实例
   * @returns {void}
   */
  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
  }

  /**
   * 获取当前主窗口的尺寸
   * @returns
   */
  async getWindowRect(): Promise<window.Rect | undefined> {
    if (this.windowStage === undefined) {
      logger.error('windowStage is undefined.');
      return;
    }

    if (!this.mainWindow) {
      this.mainWindow = await this.windowStage.getMainWindow();
    }

    const mainWinProp = this.mainWindow.getWindowProperties();
    return mainWinProp.windowRect;
  }

  /**
   * 当前主窗口是否开启沉浸模式
   * @param enable 是否开启
   * @returns {void}
   */
  setMainWindowImmersive(enable: boolean): void {
    if (this.windowStage === undefined) {
      logger.error('windowStage is undefined.');
      return;
    }
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      if (err.code) {
        logger.error(`Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      windowClass.setWindowLayoutFullScreen(enable, (err) => {
        if (err.code) {
          logger.error(`Failed to set full-screen mode. Code:${err.code}, message:${err.message}`);
          return;
        }
      });
      windowClass.setWindowSystemBarEnable(enable ? [] : ['status', 'navigation'], (err) => {
        if (err.code) {
          logger.error(`Failed to set the system bar to be invisible. Code:${err.code}, message:${err.message}`);
          return;
        }
      });
    });
  }
}
