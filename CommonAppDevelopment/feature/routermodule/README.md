# 动态路由

### 介绍

本示例将介绍如何使用动态路由跳转到模块中的页面，以及如何使用动态import的方式加载模块

**使用说明**

1. 通过动态import的方式，在需要进入页面时加载对应的模块。
2. 配置动态路由，通过WrapBuilder接口，动态创建页面并跳转。
3. 动态import变量表达式，需要DevEco Studio NEXT Developer Preview1 （4.1.3.500）版本IDE，配合hvigor 4.0.2版本使用。
4. 支持自定义路由栈管理，相关内容请参考[路由来源页的相关说明](./README_ROUTER_REFERRER.md)

### 实现思路

**[动态路由的实现](./src/main/ets/router/DynamicsRouter.ets)**

1. 注册路由

```typescript
public static createRouter(router: NavPathStack): void {
  DynamicsRouter.navPathStack = router;
}
```

2. 获取路由

```typescript
public static getRouter(): NavPathStack {
  let router = DynamicsRouter.navPathStack;
  return router as NavPathStack;
}
```

3. 通过builderName，注册WrappedBuilder对象，用于动态创建页面

```typescript
public static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
  DynamicsRouter.builderMap.set(builderName, builder);
}
```

4. 通过builderName，获取注册的WrappedBuilder对象

```typescript
public static getBuilder(builderName: string): WrappedBuilder<[object]> {
  let builder = DynamicsRouter.builderMap.get(builderName);
  if (!builder) {
    let msg = "not found builder";
    console.info(msg + builderName);
  }
  return builder as WrappedBuilder<[object]>;
}
```

5. 通过页面栈跳转到指定页面

```typescript
public static async push(router: RouterModel): Promise<void> {
  const path: string = router.path;
  const routerName: string = router.routerName;
  let param: string = router.param;
  await import(routerName).then((ns: ESObject): Promise<void> => ns.harInit(path));
  DynamicsRouter.getRouter().pushPath({ name: routerName, param: param });
}
```

**动态路由的使用**

1. 在主模块中添加动态路由和需要加载的子模块的依赖，详细代码请参考[oh-package.json](../../product/entry/oh-package.json5)。

```
...
"dependencies": {
    "@ohos/dynamicsRouter": "file:../../feature/routermodule",
    "@ohos/event-propagation": "file:../../feature/eventpropagation",
    ...
}
...
```

2. 在主模块中添加动态import变量表达式需要的参数，此处在packages中配置的模块名必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，详细代码请参考[build-profile.json5](../../product/entry/build-profile.json5)。

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

3. 在routermodule模块中添加动态路由跳转的模块名称和页面路径，RouterNameConstants中配置的模块名必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，RouterPathConstants中添加的路径是子模块中需要加载的页面的路径，详细代码请参考[RouterConstants.ets](./src/main/ets/constants/RouterConstants.ets)。

```typescript
export class RouterNameConstants {
  ...
  static readonly ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION: string = '@ohos/event-propagation';
  ...
}
export class RouterPathConstants {
  ...
  static readonly ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION: string = './src/main/ets/view/EventPropagation';
  ...
}
```

4. 在主模块中注册路由，并添加页面信息，详细代码请参考[EntryView.ets](../../product/entry/src/main/ets/pages/EntryView.ets)。

```typescript
...
@Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
@State listData: ListData[] = [
  ...
  new ListData($r("app.media.event_propagation"), '阻塞事件冒泡', RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION, 1, false, '40%', RouterPathConstants.ROUTER_PATH_EVENT_TRANSMISSION_SOLUTION, '其他'),
  ...
]
...
aboutToAppear(): void {
  DynamicsRouter.createRouter(this.pageStack);
}
```

5. 在需要加载时将页面放入路由栈，详细代码请参考[FunctionalScenes.ets](../functionalscenes/src/main/ets/FunctionalScenes.ets)和[RouterModel](./src/main/ets/model/RouterModel.ets)。

```typescript
@Builder
methodPoints(listData: ListData) {
   Column() {
   ...
  .onClick(() => {
    buildRouterModel(listData.path, listData.routerName, listData.param);
  })
}
...
function buildRouterModel(path: string, routerName: string, param: string) {
  let router: RouterModel = new RouterModel();
  router.path = path;
  router.routerName = routerName;
  router.param = param;
  DynamicsRouter.push(router);
}

```

6. 在子模块中添加动态路由的依赖，详细代码可参考[oh-package.json](../eventpropagation/oh-package.json5)。

```
...
"dependencies": {
  ...
  "@ohos/dynamicsRouter": "file:../../feature/routermodule"
}
```

7. 在子模块中添加动态加载页面组件的接口harInit，详细代码可参考[Index.ets](../eventpropagation/Index.ets)。

```typescript
export function harInit(path: string) {
  import(path);
}
```

8. 在子模块中添加动态创建组件的方法，并注册到动态路由中，详细代码可参考[EventPropagation.ets](../eventpropagation/src/main/ets/view/EventPropagation.ets)。

```typescript
...
@Builder
export function getEventPropagation(): void {
  EventPropagation();
}
        
let builderName = RouterNameConstants.ROUTER_NAME_EVENT_TRANSMISSION_SOLUTION;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(getEventPropagation);
  DynamicsRouter.registerBuilder(builderName, builder);
}
```

9. 如果5中设置的router.param是非空的，需要给8中的@Buidler接口添加参数，否则会报错，详细代码请参考[NavigationParameterTransferView](../navigationparametertransfer/src/main/ets/view/NavigationParameterTransferView.ets)。

```typescript
...
@Builder
export function getNavigationParameterTransferView(param: ESObject): void {
  NavigationParameterTransferView();
}
...
```

### 高性能知识点

本示例使用动态import的方式加载模块，只有需要进入页面时才加载对应的模块，减少主页面启动时间和初始化效率，减少内存的占用。

### 工程结构&模块类型

   ```
   routermodule                                  // har类型
   |---constants
   |   |---RouterConstants.ets                     // 常量类，用于配置动态路由跳转页面的名称和模块路径
   |---model
   |   |---RouterModel.ets                         // 路由信息类，用于存储路由的相关信息
   |---router
   |   |---DynamicsRouter.ets                      // 动态路由实现类
   ```

### 模块依赖

**不涉及**

### 参考资料

[动态路由Sample](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/ApplicationModels/DynamicRouter)