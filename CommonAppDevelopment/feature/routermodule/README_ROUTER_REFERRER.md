# 自定义路由栈管理

### 介绍

本案例将介绍如何使用路由跳转返回时获取到来源页的模块名以及路径名，在实际场景中同一页面通常会根据不同来源页展示不同的UI。

**使用说明**

无特殊使用说明，其他使用说明参考[动态路由的相关说明](./README.md)

### 实现思路

**[路由来源页的实现](./src/main/ets/router/DynamicsRouter.ets)**

1. 新增来源页字段

```typescript
export class DynamicsRouter {
  ...
  // 通过数组实现自定义栈的管理
  static routerStack: Array<RouterModel> = new Array();
  static referrer: string[] = [];
  ...
}
```

2. 注册路由

```typescript
public static createRouter(router: NavPathStack): void {
  DynamicsRouter.navPathStack = router;
  // 初始化时来源页为未定义
  let homeRouterModule = new RouterModel();
  homeRouterModule.routerName = RouterInfo.HOME_PAGE[0];
  homeRouterModule.path = RouterInfo.HOME_PAGE[1];
  DynamicsRouter.routerStack.push(homeRouterModule)
  logger.info(`DynamicsRouter create routerStack Home is: ${homeRouterModule.routerName} + ${homeRouterModule.path}`);
}
```

3. 获取路由来源页面栈

```typescript
public static getRouterReferrer(): string[] {
  return DynamicsRouter.referrer;
}
```


4. 通过页面栈跳转到指定页面

```typescript
public static async push(router: RouterModel): Promise<void> {
  const path: string = router.path;
  const routerName: string = router.routerName;
  let param: string = router.param;
  console.info('push', path, routerName);
  // TODO：知识点：通过动态import的方式引入模块，在需要进入页面时才加载模块，可以减少主页面的初始化时间及占用的内存
  await import(routerName).then(
    (ns: ESObject) => {
      console.info('harInit');
      ns.harInit(path) 
  },
    (ret: ESObject) => {
      console.info('import reason', ret);
    }
  );
  // push前记录当前页面的名字
  DynamicsRouter.getRouter().pushPath({ name: routerName, param: param });
  // 自定义栈也加入指定页面
  DynamicsRouter.routerStack.push(router);
  let referrerModel: RouterModel = DynamicsRouter.routerStack[DynamicsRouter.routerStack.length - 2];
  DynamicsRouter.referrer[0] = referrerModel.routerName;
  DynamicsRouter.referrer[1] = referrerModel.path;
  logger.info(`From DynamicsRouter.routerStack push preview module name is + ${DynamicsRouter.referrer[0]}, path is ${DynamicsRouter.referrer[1]}`);
}
```
5. 通过页面栈返回上一页

```typescript
// 通过获取页面栈并pop
public static pop(): void {
  // pop前记录的来源页为当前栈顶
  let referrerModel: RouterModel = DynamicsRouter.routerStack[DynamicsRouter.routerStack.length - 1];
  DynamicsRouter.referrer[0] = referrerModel.routerName;
  DynamicsRouter.referrer[1] = referrerModel.path;
  logger.info(`From DynamicsRouter.routerStack pop preview module name is + ${DynamicsRouter.referrer[0]}, path is ${DynamicsRouter.referrer[1]}`);
  if (DynamicsRouter.routerStack.length > 1) {
    DynamicsRouter.routerStack.pop();
  } else {
    logger.info("DynamicsRouter.routerStack is only Home.");
  }
  // 查找到对应的路由栈进行pop
  DynamicsRouter.getRouter().pop();
}

```
**路由来源页的使用**

1. 在任意模块中使用DynamicsRouter.createRouter()创建路由，在路由创建时会将主页HomePage推入自定义路由栈，并给代表来源页的referrer
字段赋值。

2. 获取路由来源页面栈，执行DynamicsRouter.getRouterStack()获得自定义路由栈，该方法和Navigation的路由栈原理一致，会在push和pop页面跳转
之前记录来源页并赋值给referrer。

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   routermodule                                  // har类型
   |---constants
   |   |---RouterConstants.ets                     // 常量类，用于配置动态路由跳转页面的名称和模块路径
   |---model
   |   |---RouterModel.ets                         // 路由信息类，用于存储路由的相关信息
   |---router
   |   |---DynamicsRouter.ets                      // 动态路由实现类 + 来源页面
   ```

### 模块依赖

**不涉及**

### 参考资料

**不涉及**