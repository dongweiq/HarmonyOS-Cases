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

import webview from '@ohos.web.webview';
import { UIContext } from '@ohos.arkui.UIContext';
import { NodeController, BuilderNode, NodeRenderType, FrameNode } from "@ohos.arkui.node";
import { PRODUCT_DATA } from '../mock/GoodsMock';
import { ProductDataModel } from '../model/GoodsModel';

/**
 * 关键流程
 * 在H5界面上通过embed标签标识同层元素，在应用侧将原生组件渲染到H5页面embed标签所在位置
 * 1.web内核识别到前端页面使用同层embed标签，基于embed标签创建独立surface绘制环境，web内核将surface和embed标签创建信息上报到应用侧
 * 2.应用侧收到embed标签创建消息后，根据业务需要，创建离屏节点数
 * 3.web内核识别embed标签事件将转发给应用侧，通过应用根据业务需要转发给对应的离屏节点数
 */

const SEARCH_BUTTON = '搜索';
const MARGIN_VERTICAL = 8;

/**
 * 组件显示宽和高参数
 */
declare class Params {
  width : number
  height : number
}

/**
 * nodeController参数
 */
declare class NodeControllerParams {
  surfaceId : string
  type : string
  renderType : NodeRenderType
  embedId : string
  width : number
  height : number
}

/**
 * 用于控制和反馈对应的NodeContainer上的节点的行为，需要与NodeContainer一起使用
 */
class SearchNodeController extends NodeController {
  private rootNode: BuilderNode<[Params]> | undefined | null;
  private embedId : string = "";
  private surfaceId : string = "";
  private renderType :NodeRenderType = NodeRenderType.RENDER_TYPE_DISPLAY;
  private componentWidth : number = 0;
  private componentHeight : number = 0;
  private componentType : string = "";

  setRenderOption(params : NodeControllerParams) {
    this.surfaceId = params.surfaceId;
    this.renderType = params.renderType;
    this.embedId = params.embedId;
    this.componentWidth = params.width;
    this.componentHeight = params.height;
    this.componentType = params.type;
  }
  /**
   * 在对应NodeContainer创建的时候调用、或者通过rebuild方法调用刷新
   */
  makeNode(uiContext: UIContext): FrameNode | null{
    this.rootNode = new BuilderNode(uiContext, { surfaceId: this.surfaceId, type: this.renderType});
    if (this.componentType === 'native/component') {
      // 创建组件树
      // Todo: 知识点：wrapBuilde封装全局@Builder
      this.rootNode.build(wrapBuilder(searchBuilder), { width : this.componentWidth, height : this.componentHeight});
    }
    // 返回FrameNode节点
    return this.rootNode.getFrameNode();
  }
  /**
   * 设置BuilderNode节点
   */
  setBuilderNode(rootNode: BuilderNode<Params[]> | null): void{
    this.rootNode = rootNode;
  }
  /**
   * 获取BuilderNode节点
   */
  getBuilderNode(): BuilderNode<[Params]> | undefined | null{
    return this.rootNode;
  }
  /**
   * 更新BuilderNode节点
   */
  updateNode(arg: Object): void {
    this.rootNode?.update(arg);
  }
  /**
   * 获取EmbedId
   */
  getEmbedId() : string {
    return this.embedId;
  }
  /**
   * 将触摸事件派发到rootNode创建出的FrameNode上
   */
  postEvent(event: TouchEvent | undefined) : boolean {
    return this.rootNode?.postTouchEvent(event) as boolean;
  }
}

// 同层渲染显示原生组件
@Component
struct SearchComponent {
  @Prop params: Params;
  controller: SearchController = new SearchController();

  build() {
    Column() {
      Column({ space: MARGIN_VERTICAL }) {
        Text($r('app.string.headline')).fontSize($r('app.string.ohos_id_text_size_body1'))
        Text($r('app.string.illustrate')).fontSize($r('app.string.ohos_id_text_size_body1'))
      }
      .backgroundColor($r('app.color.ohos_id_color_background'))
      .width($r('app.string.full_percent'))
      .padding($r('app.string.ohos_id_card_margin_start'))
      .margin({bottom: MARGIN_VERTICAL})
      .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
      // 原生Text组件
      Text($r('app.string.mall')).fontSize($r('app.string.ohos_id_text_size_body1'))
      // 原生Search组件
      Search({ placeholder: 'Type to search...', controller: this.controller })
        .searchButton(SEARCH_BUTTON)
        .width($r('app.string.full_percent'))
        .height($r('app.integer.search_component_height'))
        .backgroundColor($r('app.color.ohos_id_color_background'))
      // 原生Grid组件，Grid中包含Image和Text
      Grid() {
        // 性能知识点：此处数据量确定且数量较少，使用了ForEach，在数据量多的情况下，推荐使用LazyForeEach。[LazyForeEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)
        ForEach(PRODUCT_DATA, (item: ProductDataModel, index: number) => {
          GridItem() {
            Column({ space: MARGIN_VERTICAL }) {
              Image(item.uri).width($r('app.integer.image_size'))
              Row({ space: MARGIN_VERTICAL }) {
                Text(item.title).fontSize($r('app.string.ohos_id_text_size_body3'))
                Text(item.price).fontSize($r('app.string.ohos_id_text_size_body3'))
              }
            }
            .backgroundColor($r('app.color.ohos_id_color_background'))
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height('100%')
            .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
          }
        })
      }
      .columnsTemplate('1fr 1fr') // 2列
      .rowsTemplate('1fr 1fr ') // 2行
      .rowsGap($r('app.string.ohos_id_elements_margin_vertical_m')) // 行间距
      .columnsGap($r('app.string.ohos_id_elements_margin_vertical_m')) // 列间距
      .width($r('app.string.full_percent'))
      .height($r('app.string.half_percent'))
      .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    }
    .padding($r('app.string.ohos_id_card_margin_start'))
    .width(this.params.width)
    .height(this.params.height)
  }
}

@Builder
function searchBuilder(params: Params) {
  SearchComponent({ params: params })
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
}

@Component
export struct WebViewDemo {
  browserTabController: WebviewController = new webview.WebviewController(); // WebviewController控制器
  @State componentIdArr: Array<string> = []; // 存放componentId的数组
  private nodeControllerMap: Map<string, SearchNodeController> = new Map(); // map对象，key为componentId，value为SearchNodeController

  aboutToAppear() {
    // 配置web开启调试模式
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  build(){
    Column() {
      Stack() {
        // 性能知识点：此处componentId项确定且数量较少，使用了ForEach，在数据量多的情况下，推荐使用LazyForeEach。[LazyForeEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609)
        ForEach(this.componentIdArr, (componentId: string) => {
          NodeContainer(this.nodeControllerMap.get(componentId));
        }, (embedId: string) => embedId)
        // web组件加载本地test.html页面
        Web({ src: $rawfile("view.html"), controller: this.browserTabController })
          // 不允许执行缩放
          .zoomAccess(false)
          // Todo: 知识点：通过enableNativeEmbedMode（）配置同层渲染开关
          .enableNativeEmbedMode(true)
          // Todo: 知识点：通过onNativeEmbedLifecycleChange获取embed标签的生命周期变化数据
          .onNativeEmbedLifecycleChange((embed) => {
            // 获取web侧embed元素的id
            const componentId = embed.info?.id?.toString() as string
            if (embed.status === NativeEmbedStatus.CREATE) {
              // 创建节点控制器，设置参数并rebuild
              let nodeController = new SearchNodeController();
              // 外接纹理与WebView同层渲染
              nodeController.setRenderOption({surfaceId : embed.surfaceId as string, type : embed.info?.type as string, renderType : NodeRenderType.RENDER_TYPE_TEXTURE, embedId : embed.embedId as string, width : px2vp(embed.info?.width), height : px2vp(embed.info?.height)});
              nodeController.rebuild();
              // 根据web传入的embed的id属性作为key，将nodeController存入map
              this.nodeControllerMap.set(componentId, nodeController);
              // 将web传入的embed的id属性存入@State状态数组变量中，用于动态创建nodeContainer节点容器，需要将push动作放在set之后
              this.componentIdArr.push(componentId);
            } else if (embed.status === NativeEmbedStatus.UPDATE) {
              let nodeController = this.nodeControllerMap.get(componentId);
              nodeController?.updateNode({text: 'update', width: px2vp(embed.info?.width), height: px2vp(embed.info?.height)} as ESObject);
              nodeController?.rebuild();
            } else {
              let nodeController = this.nodeControllerMap.get(componentId);
              nodeController?.setBuilderNode(null);
              nodeController?.rebuild();
            }
          })// 获取同层渲染组件触摸事件信息
          .onNativeEmbedGestureEvent((touch) => {
            this.componentIdArr.forEach((componentId: string) => {
              let nodeController = this.nodeControllerMap.get(componentId);
              if (nodeController?.getEmbedId() === touch.embedId) {
                nodeController?.postEvent(touch.touchEvent);
              }
            })
          })
      }
    }.backgroundColor($r('app.color.ohos_id_color_sub_background'))
  }
}