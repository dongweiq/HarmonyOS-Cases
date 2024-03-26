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

/**
 * Web预渲染
 */
import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import webview from '@ohos.web.webview';
import { connection } from '@kit.NetworkKit';

interface Data {
  url: string;
  controller: webview.WebviewController;
}

/**
 * Builder中为动态组件的具体组件内容
 * 调用onActive，开启渲染
 */
@Builder
function WebBuilder(data: Data) {
  Web({ src: data.url, controller: data.controller })
    .onPageBegin(() => {
      data.controller.onActive();
    })
    .width($r("app.string.full_size"))
    .height($r("app.string.full_size"))
}


const wrap: WrappedBuilder<Data[]> = wrapBuilder<Data[]>(WebBuilder);

/**
 * 用于控制和反馈对应的NodeContainer上的节点的行为，需要与NodeContainer一起使用
 */
export class NWebNodeController extends NodeController {
  private rootNode: BuilderNode<Data[]> | null = null;

  /**
   * 必须要重写的方法，用于构建节点数、返回节点挂载在对应NodeContainer中
   * 在对应NodeContainer创建的时候调用、或者通过rebuild方法调用刷新
   */
  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootNode) {
      return this.rootNode.getFrameNode();
    }
    return null; // 返回null控制动态组件脱离绑定节点
  }

  /**
   * 自定义函数，可作为初始化函数使用
   * 通过UIContext初始化BuilderNode，再通过BuilderNode中的build接口初始化@Builder中的内容
   */
  initWeb(url: string, uiContext: UIContext, controller: WebviewController) {
    if (this.rootNode) {
      return;
    }
    // 创建节点与动态web组件
    this.rootNode = new BuilderNode(uiContext);
    this.rootNode.build(wrap, { url: url, controller: controller });
  }
}

interface CurrentNode {
  url: string | null;
  webController: webview.WebviewController | null;
  nWebController: NWebNodeController | null;
}

// 当前的Node
const currentNode: CurrentNode = { url: null, nWebController: null, webController: null };

function clear() {
  currentNode.url = null;
  currentNode.webController = null;
  currentNode.nWebController = null;
}

export function createNWeb(url: string, uiContext: UIContext): void {
  if (!connection.hasDefaultNetSync()) {
    return;
  }
  clear(); // 每次创建都先将旧的置空
  let baseNode = new NWebNodeController();
  let controller = new webview.WebviewController();
  // 初始化自定义web组件
  baseNode.initWeb(url, uiContext, controller);
  currentNode.url = url;
  currentNode.webController = controller;
  currentNode.nWebController = baseNode;
}

/**
 * 获取NodeController
 */
export const getNWeb = (url: string, uiContext: UIContext): NWebNodeController | null => {
  if (currentNode.url != url) {
    createNWeb(url, uiContext);
  }
  return currentNode.nWebController;
}