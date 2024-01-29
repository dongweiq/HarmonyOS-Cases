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

// TODO：知识点：将Native接口导出。
export const AkiThreadsCallJs: (param: number) => void;
export class JSBind {
  // 参数name用于指定绑定的JavaScript函数名，用于Native索引。参数func表示被绑定的JavaScript函数。
  static bindFunction: (name: string, func: Function) => number;
}