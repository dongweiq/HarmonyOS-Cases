<p align="center">
  <h1 align="center">Navigation开发 页面切换场景范例</h1>
</p>

## 简介

在应用开发时，我们常常遇到，需要在应用内多页面跳转场景时中使用`Navigation`导航组件做统一的页面跳转管理，它提供了一系列属性方法来设置页面的标题栏、工具栏以及菜单栏的各种展示样式。除此之外还拥有动态加载，navPathStack路由跳转。

本文就以Navigation页面切换范例为例，来展开讲解Navigation以上的技术点，帮助开发者快速学习。

## 场景概述

ArkUI中，应用内导航组件Navigation一般作为Page页面的根容器， Navigation组件主要包含主页和内容页。    
主页内容区默认首页显示导航内容(Navigation的子组件) 或非首页显示(NavDestination的子组件)，首页和非首页通过路由进行切换。  
Navigation的路由切换的方式有两种，本次示例主要介绍NavPathStack的使用。
* 在API Version 9上，首页导航内容需要配合NavRouter组件实现页面路由。
* 从API Version 10开始，首页推荐使用NavPathStack配合NavDestination属性进行页面路由。

应用内导航组件Navigation还可以通过mode属性实现多设备适配，具体请参考[MULTIDEVICE_ADAPTATION.md](../../doc/MULTIDEVICE_ADAPTATION.md)

> 通过本篇文章的学习，你将学会：    
1.如何使用**NavPathStack路由转场**  
2.如何在**Navigation中跨包引用hsp**  
3.如何在**Navigation中使用动态加载**

## Router与Navigation适用场景对比
| 组件  | 适用场景 | 特点                | 转场动画效果对比 |
|-----|------|-------------------|----------|
| Router | 模块间与模块内页面切换  | 通过每个页面的url实现模块间解耦 | 页面平推转场效果 |
| Navigation | 模块内页面切换  | 通过组件级路由统一路由管理     | 向右折叠转场效果 |

## 使用NavPathStack路由转场
* NavPathStack有两种路由切换方法，一种是pushPath，如主页---->设置页面，通过使用this.pageStack.pushPath({ name: url })进行跳转，另外一种是pushPathByName，如主页---->详情页面，通过使用this.pageStack.pushPathByName(name, item)进行跳转，其中item为需要传递的参数。

    * NavPathStack支持pop、move、clear方法的使用；pop方法的作用是弹出路由栈栈顶元素，如首页进入商品详情页面，在详情页面使用this.pageStack.pop()方法返回到首页，clear方法的作用是清除栈中所有页面，
      如首页跳转到详情页面，详情页面再进入直播页面，在直播页面通过使用this.pageStack.clear()直接返回到首页。除此之外，还有popTo(回退路由栈到第一个名为name的NavDestination页面)、
      popToIndex(回退路由栈到index指定的NavDestination页面)、moveToTop(将第一个名为name的NavDestination页面移到栈顶)、moveIndexToTop(将index指定的NavDestination页面移到栈顶)方法,
      由于本示例暂时没有合适的按钮去承载这些功能，所以本示例未体现。

    * 路由栈信息,如下所示
        ```
        获取栈中所有NavDestination页面的名称：this.pageInfos.getAllPathName()
        获取index指定的NavDestination页面的参数信息：this.pageInfos.getParamByIndex(1)
        获取全部名为name的NavDestination页面的参数信息：this.pageInfos.getParamByName('pageTwo')
        获取全部名为name的NavDestination页面的位置索引：this.pageInfos.getIndexByName('pageOne')
        获取栈大小：this.pageInfos.size()
        ```

### 实现思路

> 以Navigation组件为基础，通过[路由管理](../../feature/routermodule/README.md)实现页面之间的跳转。

### 开发步骤

**Navigation中使用路由跳转页面**

1. 在onClick事件中，调用路由管理中的push方法。源码参考[FunctionalScenes.ets](../../feature/functionalscenes/src/main/ets/FunctionalScenes.ets)
  
    ```ts
    Column()
      .onClick(() => {
        DynamicsRouter.push(listData.routerInfo, listData.param);
      })
    ```

2. 在DynamicsRouter的push方法中，通过NavPathStack.pushPath方法实现页面的跳转。源码参考[DynamicsRouter](../../feature/routermodule/src/main/ets/router/DynamicsRouter.ets)

    ```ts
    public static async push(routerInfo: RouterInfo, param?: string): Promise<void> {
      const pageName: string = routerInfo.pageName;
      const moduleName: string = routerInfo.moduleName;
      ...
      if (isImportSucceed) {
        const builderName: string = moduleName + "/" + pageName;
        DynamicsRouter.getNavPathStack().pushPath({ name: builderName, param: param });
      }
    }
    ```
   
**新模块中配置路由管理**

1. 添加需要加载的子模块的依赖，详细代码请参考[oh-package.json](../../product/entry/oh-package.json5)。

    ```
    "dependencies": {
      "@ohos/event-propagation": "file:../../feature/eventpropagation",
      ...
    }
    ```

2. 添加动态import变量表达式需要的参数，此处在packages中配置的模块名必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，详细代码请参考[build-profile.json5](../../product/entry/build-profile.json5)。

    ```
    ...
    "buildOption": {
      "arkOptions": {
        "runtimeOnly": {
          "packages": [
            "@ohos/event-propagation",
            ...
          ]
        }
      }
    }
    ```

3. 在routermodule模块中添加需要跳转的moduleName（模块名）和pageName（页面名），RouterInfo中配置的moduleName必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，RouterInfo中添加的pageName是子模块中需要加载的页面，详细代码请参考[RouterInfo.ets](./src/main/ets/constants/RouterInfo.ets)。

    ```ts
    export class RouterInfo {
      moduleName: string = '';
      pageName: string = '';
    
      constructor(moduleName: string, pageName: string) {
        this.moduleName = moduleName;
        this.pageName = pageName;
      }
    
      ...
      static readonly EVENT_TRANSMISSION_SOLUTION: RouterInfo = new RouterInfo('@ohos/event-propagation', 'EventPropagation');
      ...
    }
    ```

4. 在WaterFlowData.ets中，将子模块要加载的页面，添加到列表中，详细代码请参考[WaterFlowData.ets](../../product/entry/src/main/ets/data/WaterFlowData.ets)。

    ```ts
    export const waterFlowData: SceneModuleInfo[] = [
      ...
      new SceneModuleInfo($r("app.media.event_propagation"), '阻塞事件冒泡', RouterInfo.EVENT_TRANSMISSION_SOLUTION, '其他', 1),
      ...
    }
    ```

5. 在子模块中添加路由管理的依赖，详细代码可参考[oh-package.json](../eventpropagation/oh-package.json5)。

    ```
    ...
    "dependencies": {
      ...
      "@ohos/dynamicsrouter": "file:../../feature/routermodule"
    }
    ```

6. 在子模块中添加动态加载页面组件的接口harInit，其中pageName和RouterInfo中配置的pageName相同，import()接口中传入的参数，是页面的相对路径。详细代码可参考[Index.ets](../eventpropagation/Index.ets)。
   如果模块中有多个页面需要跳转，则需要配置多个pageName和页面路径，并且pageName和页面路径需要一一对应，否则无法跳转到预期中的页面，详细代码可参考[barchart模块中的Index.ets](../barchart/Index.ets)。

    ```ts
    export function harInit(pageName: string) {
      switch (pageName) {
        case RouterInfo.EVENT_TRANSMISSION_SOLUTION.pageName:
          import('./src/main/ets/view/EventPropagation');
          break;
      }
    }
    ```
   
7. 在子模块中添加动态创建组件的方法，并注册到路由管理中，详细代码可参考[EventPropagation.ets](../eventpropagation/src/main/ets/view/EventPropagation.ets)。

    ```ts
    ...
    @Builder
    export function getEventPropagation(): void {
      EventPropagation();
    }
    
    DynamicsRouter.registerRouterPage(RouterInfo.EVENT_TRANSMISSION_SOLUTION,wrapBuilder(getEventPropagation));
    ```

## 参考文档

[1] [桔子购物sample · OpenHarmony - Gitee.com](https://gitee.com/openharmony/applications_app_samples/tree/master/code/Solutions/Shopping/OrangeShopping)

[2] [路由管理](../../feature/routermodule/README.md)