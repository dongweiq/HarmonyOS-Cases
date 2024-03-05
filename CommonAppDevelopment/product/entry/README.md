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

> 通过this.pageStack.pushPath({ name: url param: item })进行页面之间的跳转，[navpathstack详情](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/arkui-ts/ts-basic-components-navigation.md/#navpathstack10)。

### 开发步骤

1. 在onClick事件中，调用动态路由中的push方法。源码参考[FunctionalScenes.ets](../../feature/functionalscenes/src/main/ets/FunctionalScenes.ets)
  ```ts
  Column()
    .onClick(() => {
      DynamicsRouter.push(listData.routerInfo, listData.param);
    })
  ```

2. 在DynamicsRouter的push方法中，通过NavPathStack中的pushPath方法实现页面的跳转。源码参考[DynamicsRouter](../../feature/routermodule/src/main/ets/router/DynamicsRouter.ets)

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

## 参考文档

[1] [桔子购物sample · OpenHarmony - Gitee.com](https://gitee.com/openharmony/applications_app_samples/tree/master/code/Solutions/Shopping/OrangeShopping)
