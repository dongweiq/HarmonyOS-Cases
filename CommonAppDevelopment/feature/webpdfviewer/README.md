# Web组件预览PDF文件实现案例

### 介绍

本案例通过Web组件实现**预览本地PDF文件**和**预览网络PDF文件**，代码为Tabs容器组件包含了两个独立的TabContent子组件，分别标示为**预览本地PDF文件**和**预览网络PDF文件**。每个子组件内部构建一个Web组件。第一个Web组件利用resource协议关联本地PDF文件路径以预览本地存储的PDF资源；第二个Web组件则通过配置网络链接属性，实现从互联网加载并预览远程PDF文件内容。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/web_pdf_viewer.gif)

**使用说明**

1. 进入页面默认预览本地PDF文件，点击预览网络PDF文件按钮可以切换到预览网络PDF文件模块。

### 实现思路

1. 本地PDF加载:通过resource协议（需在工程resources/rawfile 目录下添加PDF文件,通过RESOURCE_URL获取的PDF文件）来实现本地PDF文件资源的装载与呈现，在无需网络连接的情况下，也能顺利加载并预览用户本地PDF资源。
```javascript
Web({ src: $rawfile(RESOURCE_URL), controller: this.controller })
  .onProgressChange((event) => {
    if (event) {
      this.localProgressValue = event.newProgress
        if (this.localProgressValue >= TOTAL_VALUE) {
          this.isHiddenLocalProgress = false;
        }
     }
 })
 .domStorageAccess(true) // 设置是否开启文档对象模型存储接口（DOM Storage API）权限，默认未开启。
```
2. 网络PDF加载:通过设置网络链接属性，能够对接互联网上的PDF文件资源。提供有效的远程PDF文件URL（REMOTE_URL），实现云端PDF资源的加载与预览。
```javascript
Web({ src: REMOTE_URL, controller: this.controller })
  .onProgressChange((event) => {
    if (event) {
      this.remoteProgressValue = event.newProgress
        if (this.remoteProgressValue >= TOTAL_VALUE) {
          this.isHiddenRemoteProgress = false;
        }
     }
 })
 .domStorageAccess(true) // 设置是否开启文档对象模型存储接口（DOM Storage API）权限，默认未开启。
```
**注：** 其中domStorageAccess 方法用于控制Web中对文档对象模型存储（DOM Storage API）的启用状态，若将其设置为 false，可能会影响到PDF文件在Web中的预览功能，因此需要将其设为 true 以确保PDF文件能够正常预览。

### 高性能知识点

**不涉及**

### 工程结构&模块类型

```
webpdfviewer                                     // har类型
|---view
|   |---WebPDFViewer.ets                         // PDF加载主页 
|---rawfile
|   |---sample.pdf                               // PDF文件资源
```

### 模块依赖

本实例依赖common模块来实现[资源](../../common/utils/src/main/resources/base/element)的调用以及路由模块来[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。

### 参考资料

[Web](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-web-0000001774281246)

[Tabs](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-navigation-tabs-0000001820999773)

[Progress](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-progress-0000001820880889)



