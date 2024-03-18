# 应用新功能引导实现案例

### 介绍

本文介绍如何使用**high_light_guide**三方库完成应用新版本功能导航。通过高亮区域与蒙版背景的明暗度对比，让用户快速锁定重点功能，了解版本变更和业务入口。

### 效果图预览

![动画](../../product/entry/src/main/resources/base/media/direct.gif)

**使用说明**

1. 点击页面上对应按钮或空白区域进入下一个提示，直至提示完成。

### 实现思路

1. 在需要使用的页面引入high_light_guide库中的引导页组件。

   ```typescript
   // 引入引导页组件
   import { HighLightGuideBuilder, HighLightGuideComponent, Controller, GuidePage, HighLightShape, RectF } from '@ohos/high_light_guide';
   ```

2. 初始化引导页构建类，通过addHighLight绑定对应id组件的高光。

   ```typescript
   // 初始化引导页构建类
   aboutToAppear() {
     this.builder = new HighLightGuideBuilder()
       .alwaysShow(true)
       .addGuidePage(GuidePage.newInstance()
         .addHighLightWithOptions('test', HighLightShape.CIRCLE, options)// 为对应id组件绑定高光
         .setHighLightIndicator(this.SimpleIndicator))// 绑定高光功能引导布局
   }
   ```

3. 添加引导页布局。

   ```typescript
   build() {
     Stack() {
       ...
       // 添加引导页布局
       HighLightGuideComponent({
         highLightContainer: this.HighLightComponent, // 引导页覆盖时的内容布局插槽
         currentHLIndicator: null, // 引导页的引导层插槽
         builder: this.builder, // 引导页的通用配置构建类
         onReady: (controller: Controller) => { // 引导页准备好的回调，获取引导页控制器
           this.controller = controller;
         }
       })
       ...
     }
   }
   ```

4. 自定义Builder，分别设定基础布局和引导层内容。

   ```typescript
   @Builder
   private HighLightComponent() {
     Column() {
       ... // 布局内容
     }.alignItems(HorizontalAlign.Start)
     .width('100%')
     .height('100%');
   }
   
   @Builder
   private SimpleIndicator() {
     ... // 引导层内容
   }
   ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   highlightguide                               // har类型
   |---src\main\ets\pages
   |   |---Index.ets                            // 功能引导页面
   ```

### 模块依赖

[动态路由模块](../../feature/routermodule/src/main/ets/router/DynamicsRouter.ets)实现页面动态加载

### 参考资料

[high_light_guide三方库]([ohos_highlightguide: 基于OpenHarmony的快速实现新手引导层的库，通过简洁链式调用，快速实现引导层的显示。 - Gitee.com](https://gitee.com/openharmony-sig/ohos_highlightguide/tree/master#high_light_guide))