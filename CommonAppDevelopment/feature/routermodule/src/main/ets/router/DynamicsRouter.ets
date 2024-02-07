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
import { RouterModel } from '../model/RouterModel';

/**
 * 动态路由
 *
 * 实现步骤：
 * 1.将主模块的NavPathStack传入createRouter接口，注册路由
 * 2.通过registerBuilder接口，将需要动态加载的模块注册到路由中
 * 3.通过push接口，跳转到指定的模块页面
 */

export class DynamicsRouter {
  // 管理需要动态导入的模块，key是模块名，value是WrappedBuilder对象，动态调用创建页面的接口
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  static navPathStack: NavPathStack = new NavPathStack();

  // 通过名称注册builder
  public static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
    DynamicsRouter.builderMap.set(builderName, builder);
  }

  // 通过名称获取builder
  public static getBuilder(builderName: string): WrappedBuilder<[object]> {
    let builder = DynamicsRouter.builderMap.get(builderName);
    if (!builder) {
      let msg = "not found builder";
      console.info(msg + builderName);
    }
    return builder as WrappedBuilder<[object]>;
  }

  // 注册router
  public static createRouter(router: NavPathStack): void {
    DynamicsRouter.navPathStack = router;
  }

  // 通过名称获取router
  public static getRouter(): NavPathStack {
    let router = DynamicsRouter.navPathStack;
    return router as NavPathStack;
  }

  // 通过获取页面栈跳转到指定页面
  public static async push(router: RouterModel): Promise<void> {
    const path: string = router.path;
    const routerName: string = router.routerName;
    let param: string = router.param;
    // TODO：知识点：通过动态import的方式引入模块，在需要进入页面时才加载模块，可以减少主页面的初始化时间及占用的内存
    await import(routerName).then((ns: ESObject): Promise<void> => ns.harInit(path));
    // 查找到对应的路由栈进行跳转
    DynamicsRouter.getRouter().pushPath({ name: routerName, param: param });
  }

  // 通过获取页面栈并pop
  public static pop(): void {
    // 查找到对应的路由栈进行pop
    DynamicsRouter.getRouter().pop();
  }

  // 通过获取页面栈并将其清空
  public static clear(): void {
    // 查找到对应的路由栈进行pop
    DynamicsRouter.getRouter().clear();
  }
}