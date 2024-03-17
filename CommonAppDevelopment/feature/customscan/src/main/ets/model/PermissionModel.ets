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

import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { logger } from '@ohos/utils/Index';
import { BusinessError } from '@kit.BasicServicesKit';

export default class PermissionModel {
  /**
   * 单例模型私有化构造函数，使用getInstance静态方法获得单例
   */
  private constructor() {
  }

  /**
   * PermissionModel 单例
   */
  private static instance?: PermissionModel;

  /**
   * 获取PermissionModel单例实例
   * @returns {PermissionModel} PermissionModel
   */
  static getInstance(): PermissionModel {
    if (!PermissionModel.instance) {
      PermissionModel.instance = new PermissionModel();
    }

    return PermissionModel.instance;
  }

  /**
   * 检测是否已授权
   * @param {Permissions} permissionName 检测授权的权限名
   * @returns {boolean} 检测结果
   */
  async checkPermission(permissionName: Permissions): Promise<boolean> {
    // 检测用户是否已经授权
    const grantStatus: abilityAccessCtrl.GrantStatus = await this.reqCurGrantStatus(permissionName);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 用户之前已授权，可以直接访问目标操作
      return true;
    }

    // 用户未授权
    return false;
  }

  /**
   * 检测权限状态
   * @param {Permissions} permission 检测授权的权限名
   * @returns {Promise<abilityAccessCtrl.GrantStatus>} 权限状态
   */
  async reqCurGrantStatus(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      const bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }

  /**
   * 向用户申请授权
   * @param {Permissions} permissionName 申请授权的权限名
   * @returns {boolean} 申请授权结果
   */
  async requestPermission(permissionName: Permissions) {
    // 向用户申请授权
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatusArr = await atManager.requestPermissionsFromUser(context, [ permissionName ]);
    const grantStatus = grantStatusArr.authResults[0];
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 用户授权，可以继续访问目标操作
      return true;
    }

    return false;
  }
}