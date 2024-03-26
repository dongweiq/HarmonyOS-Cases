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
import { HttpProxyCacheServer } from '@ohos/video-cache';

const CONTEXT_STR: string = 'context';
const SERVER_STR: string = 'server';

export default class GlobalProxyServer {
  private static instance: GlobalProxyServer | null = null;
  private objects: Map<string, Object | null> = new Map<string, Object | null>();

  public static getInstance(): GlobalProxyServer {
    if (!GlobalProxyServer.instance) {
      GlobalProxyServer.instance = new GlobalProxyServer();
    }
    return GlobalProxyServer.instance;
  }

  /**
   * 获取上下文信息
   * @returns
   */
  getContext(): common.UIAbilityContext {
    return this.objects.get(CONTEXT_STR) as common.UIAbilityContext;
  }

  /**
   * 设置上下文信息
   * @param context
   */
  setContext(context: common.UIAbilityContext): void {
    this.objects.set(CONTEXT_STR, context);
  }

  /**
   * 获取服务器
   * @returns
   */
  getServer(): HttpProxyCacheServer {
    return this.objects.get(SERVER_STR) as HttpProxyCacheServer;
  }

  /**
   * 设置服务器
   * @param objectClass
   */
  setServer(objectClass: HttpProxyCacheServer): void {
    try {
      const currentServer: HttpProxyCacheServer = this.getServer();
      currentServer.shutdown();
    } catch (err) {
    }
    this.objects.set(SERVER_STR, objectClass);
  }
}

