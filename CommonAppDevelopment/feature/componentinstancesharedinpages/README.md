# 页面间共享组件实例的案例

### 介绍

本示例提供组件实例在页面间共享的解决方案：通过[Stack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-stack-0000001774280970)容器，下层放地图组件，上层放[Navigation](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation-0000001821000861)组件来管理页面，页面可以共享下层的地图组件，页面中需要显示地图的区域设置为透明，并参考[触摸交互控制](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/6_31_u89e6_u6478_u4ea4_u4e92_u63a7_u5236-0000001821000817)，设置事件透传及响应区域。
### 效果图预览

![](../../product/entry/src/main/resources/base/media/componentinstancesharedinpages.gif)

**使用说明**

页面间共享地图组件的场景：
- 使用地图组件替换代码中[模拟的地图组件](src/main/ets/components/MapComponent.ets)。
- 添加新页面，需要预留地图组件的显示区域，参考[首页代码](src/main/ets/pages/MainPage.ets)的实现。

其他组件实例共享的场景：
- 参考实现思路即可。

### 实现思路
#### 场景：组件实例页面间共享

本示例实现模拟的地图组件实例在两个页面间共享。

- 通过Stack容器，下层放地图组件，上层放Navigation组件管理两个页面，且需要设置Navigation组件的事件透传到地图组件，[源码参考](src/main/ets/pages/ComponentSharedInPages.ets)。
```
  build() {
    Stack({alignContent: Alignment.Bottom}) {
      // 地图组件放在底层，navigation组件放在上层，navigation中的页面需要显示地图组件的位置处设置透明和事件透传
      MapComponent()
      // 应用主页用NavDestination承载，Navigation为空页面直接跳转到MainPage主页面
      Navigation(this.pageStackForComponentSharedPages) {
      }
      .onAppear(()=>{
        this.pageStackForComponentSharedPages.pushPathByName("MainPage", null, false)
      })
      .hideTitleBar(true)
      // navigation组件设置事件透传给兄弟组件
      .hitTestBehavior(HitTestMode.Transparent)
      .navDestination(this.pageMap)
    }
    .width('100%')
    .height('100%')
  }
```
- Navigation中的页面需要显示地图的区域设置透明,由于本示例主页面是一个Scroll，所以选择放一个空的Column容器组件占位，默认是透明[源码参考](src/main/ets/pages/MainPage.ets)。
```
 // 页面用于显示地图的区域，放一个空的容器组件，背景默认透明，来显示下层的地图组件（该组件父组件也需要设置透明）
 Column() {
 }
 .width('100%')
 .height(this.transParentInitHeight)
```
- 为避免上层内容区域(非透明区域)的事件也影响下层地图组件，需要分别设置地图组件和内容区域对事件的响应范围，两组响应区域不重叠，随内容区域的变化而变化。
```
  // 地图组件的手势事件响应区域设置
  .responseRegion({
    x: 0,
    y: 0,
    width: '100%',
    height: this.mapResponseRegionHeight
  })
```
```
  // 主页面的手势事件响应区域设置
  .responseRegion({
    x: 0,
    y: this.mapResponseRegionHeight,
    width: '100%',
    height: this.pageHeight - this.mapResponseRegionHeight
  })
```
- 主页面Scroll滑动过程中Column组件(透明，用于显示下层地图组件)逐渐划出页面，地图的显示区域随之变化，因此需要滑动过程中更新地图的事件响应区域[源码参考](src/main/ets/pages/MainPage.ets)。
```
  .onScrollFrameBegin((offset) => {
    this.scrollCurOffset = this.scroller.currentOffset().yOffset;
    this.mapResponseRegionHeight =
      this.transParentInitHeight - this.scrollCurOffset > 0 ? this.transParentInitHeight - this.scrollCurOffset:0;
    return {offsetRemain : offset}
  })
```
### 高性能知识点
- [ForEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-foreach-0000001524537153-V2)循环渲染会一次性加载所有组件，会导致页面启动时间长，影响用户体验，长列表场景推荐使用数据懒加载，参考[优化指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/best-practices-long-list-0000001728333749)。
- [onActionUpdate](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-gestures-pangesture-0000001774280890#ZH-CN_TOPIC_0000001774280890__事件)、[onScrollFrameBegin](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-scroll-0000001821000913#ZH-CN_TOPIC_0000001821000913__事件)、[onAreaChange](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-component-area-change-event-0000001820880805)，这些函数是系统高频回调函数，避免在函数中进行冗余或耗时操作。例如应该减少或避免在函数打印日志，会有较大的性能损耗。

### 工程结构&模块类型

   ```
   componentinstancesharedinpages                  // har类型
   |---src/main/ets/pages
   |   |---ComponentSharedInPages.ets              // 视图层-壳页面 
   |   |---MainPage.ets                            // 视图层-主页面
   |   |---TakeTaxiDetailPage.ets                  // 视图层-打车页面
   |---src/main/ets/Components
   |   |---MapComponent.ets                        // 视图层-地图组件 
   |---src/main/ets/model
   |   |---CommonConstants.ets                     // 模型层-通用常量 
   ```

### 模块依赖
本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)
的调用，依赖routermodule模块来实现[路由注册管理](../routermodule/Index.ets)。

### 参考资料
[Stack参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-stack-0000001774280970)

[Navigation参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation-0000001821000861)

[触摸交互控制参考文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/6_31_u89e6_u6478_u4ea4_u4e92_u63a7_u5236-0000001821000817)