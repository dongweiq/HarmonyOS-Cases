/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { RouterInfo } from '../constants/RouterInfo';
import { logger } from '@ohos/base';

/**
 * 动态路由
 *
 * 实现步骤：
 * 1.将主模块的NavPathStack传入createRouter接口，注册路由
 * 2.通过registerBuilder接口，将需要动态加载的模块注册到路由中
 * 3.通过push接口，跳转到指定的模块页面
 */

const LOGGER_TAG: string = 'Dynamics import failed , reason : ';

export class DynamicsRouter {
  // 管理需要动态导入的模块，key是模块名，value是WrappedBuilder对象，动态调用创建页面的接口
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  static navPathStack: NavPathStack = new NavPathStack();
  // 通过数组实现自定义栈的管理
  static routerStack: Array<RouterInfo> = new Array();
  static referrer: string[] = [];

  // 通过名称注册builder
  private static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
    DynamicsRouter.builderMap.set(builderName, builder);
  }

  // 通过名称获取builder
  public static getBuilder(builderName: string): WrappedBuilder<[object]> {
    let builder = DynamicsRouter.builderMap.get(builderName);
    if (!builder) {
      let msg = "not found builder";
      logger.info(msg + builderName);
    }
    return builder as WrappedBuilder<[object]>;
  }

  // 注册router
  public static createNavPathStack(navPathStack: NavPathStack): void {
    DynamicsRouter.navPathStack = navPathStack;
    // 初始化时来源页为未定义
    DynamicsRouter.routerStack.push(RouterInfo.HOME_PAGE)
    logger.info(`DynamicsRouter create routerStack Home is: ${RouterInfo.HOME_PAGE.moduleName} + ${RouterInfo.HOME_PAGE.pageName}`);
  }

  // 通过名称获取router
  private static getNavPathStack(): NavPathStack {
    return DynamicsRouter.navPathStack;
  }

  // 获取路由来源页面栈
  public static getRouterReferrer(): string[] {
    return DynamicsRouter.referrer;
  }

  // 通过获取页面栈跳转到指定页面
  public static async push(routerInfo: RouterInfo, param?: string): Promise<void> {
    const pageName: string = routerInfo.pageName;
    const moduleName: string = routerInfo.moduleName;
    // 动态加载模块是否成功
    let isImportSucceed: boolean = false;
    // TODO：知识点：通过动态import的方式引入模块，在需要进入页面时才加载模块，可以减少主页面的初始化时间及占用的内存
    await import(moduleName).then((result: ESObject) => {
      // 动态加载模块成功时，通过模块中的harInit接口加载页面
      result.harInit(pageName);
      isImportSucceed = true;
    }, (error: ESObject) => {
      // 动态加载模块失败时，打印错误日志
      logger.error(LOGGER_TAG, error);
    });
    if (isImportSucceed) {
      // 使用moduleName和pageName生成builderName，通过pushPath加载页面
      const builderName: string = moduleName + "/" + pageName;
      // 查找到对应的路由栈进行跳转
      DynamicsRouter.getNavPathStack().pushPath({ name: builderName, param: param });
      // 自定义栈也加入指定页面
      DynamicsRouter.routerStack.push(routerInfo);
      let referrerModel: RouterInfo = DynamicsRouter.routerStack[DynamicsRouter.routerStack.length - 2];
      DynamicsRouter.referrer[0] = referrerModel.moduleName;
      DynamicsRouter.referrer[1] = referrerModel.pageName;
      logger.info(`From DynamicsRouter.routerStack push preview module name is + ${DynamicsRouter.referrer[0]}, path is ${DynamicsRouter.referrer[1]}`);
    }
  }

  // 通过获取页面栈并pop
  public static pop(): void {
    // pop前记录的来源页为当前栈顶
    let referrerModel: RouterInfo = DynamicsRouter.routerStack[DynamicsRouter.routerStack.length - 1];
    DynamicsRouter.referrer[0] = referrerModel.moduleName;
    DynamicsRouter.referrer[1] = referrerModel.pageName;
    logger.info(`From DynamicsRouter.routerStack pop preview module name is + ${DynamicsRouter.referrer[0]}, path is ${DynamicsRouter.referrer[1]}`);
    if (DynamicsRouter.routerStack.length > 1) {
      DynamicsRouter.routerStack.pop();
    } else {
      logger.info("DynamicsRouter.routerStack is only Home.");
    }
    // 查找到对应的路由栈进行pop
    DynamicsRouter.getNavPathStack().pop();
  }

  // 通过获取页面栈并将其清空
  public static clear(): void {
    // 查找到对应的路由栈进行pop
    DynamicsRouter.getNavPathStack().clear();
  }

  /**
   * 注册动态路由需要加载的页面
   *
   * @param pageName 页面名，需要动态加载的页面名称
   * @param wrapBuilder wrapBuilder对象
   */
  public static registerRouterPage(routerInfo: RouterInfo, wrapBuilder: WrappedBuilder<[object]>) {
    let builderName: string = routerInfo.moduleName + "/" + routerInfo.pageName;
    if (!DynamicsRouter.getBuilder(builderName)) {
      DynamicsRouter.registerBuilder(builderName, wrapBuilder);
    }
  }
}