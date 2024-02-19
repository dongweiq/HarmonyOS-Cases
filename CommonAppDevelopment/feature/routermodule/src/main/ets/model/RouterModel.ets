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
import { DynamicsRouter } from '../router/DynamicsRouter';

// 路由信息类
export class RouterModel {
  // 模块路径，用于动态加载模块
  path: string = "";
  // 模块名，用于页面跳转
  routerName: string = "";
  // 需要传入页面的参数
  param: string = "";
}

// 创建路由信息，并放到路由栈中
export function buildRouterModel(path: string, routerName: string, param: string) {
  let router: RouterModel = new RouterModel();
  router.path = path;
  router.routerName = routerName;
  router.param = param;
  DynamicsRouter.push(router);
}