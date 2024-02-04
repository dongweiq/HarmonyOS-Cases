# 动态路由

### 介绍

本示例将介绍如何使用动态路由跳转到模块中的页面，以及如何使用动态import的方式加载模块

**使用说明**

1. 通过动态import的方式，在需要进入页面时加载对应的模块。
2. 配置动态路由，通过WrapBuilder接口，动态创建页面并跳转。
3. 动态import变量表达式，需要DevEco Studio NEXT Developer Preview1 （4.1.3.500）版本IDE，配合hvigor 4.0.2版本使用。

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
  await import(path).then((ns: ESObject): Promise<void> => ns.harInit());
  DynamicsRouter.getRouter().pushPath({ name: routerName, param: param });
}
```

**动态路由的使用**

1. 在主模块中添加动态路由和需要加载的子模块的依赖，详细代码请参考[oh-package.json](../functionalscenes/oh-package.json5)。

```
...
"dependencies": {
    "@ohos/dynamicsRouter": "file:../../feature/dynamicsrouter",
    "@ohos/event-propagation": "file:../../feature/eventpropagation",
    "@ohos/nativerawfile": "file:../../feature/nativerawfile",
    "@ohos/custom-tabbar": "file:../../feature/customtabbar",
    "@ohos/secondarylinkage": "file:../../feature/secondarylinkage",
    "@ohos/barchart": "file:../../feature/barchart",
    ...
}
...
```

2. 在主模块中添加动态import变量表达式需要的配置参数，详细代码请参考[build-profile.json5](../functionalscenes/build-profile.json5)。

```
...
"buildOption": {
    "arkOptions": {
      "runtimeOnly": {
        "sources": [
        ],
        "packages": [
          "@ohos/event-propagation",
          "@ohos/nativerawfile",
          "@ohos/custom-tabbar",
          "@ohos/secondarylinkage",
          "@ohos/barchart",
        ...
}
```

3. 在dynamicsrouter模块中添加动态路由跳转的页面名称和模块路径，详细代码请参考[RouterConstants.ets](./src/main/ets/constants/RouterConstants.ets)。

```typescript
export class RouterNameConstants {
  static readonly ROUTER_NAME_ADDRESS_EXCHANGE: string = 'addressExchange';
  static readonly ROUTER_NAME_BAR_CHAT: string = 'barChartSolution';
  static readonly ROUTER_NAME_CUSTOM_TAB_BAR: string = 'customTabBar';
  ...
}
export class RouterPathConstants {
  static readonly ROUTER_PATH_ADDRESS_EXCHANGE: string = '@ohos/addressexchange';
  static readonly ROUTER_PATH_BAR_CHAT: string = '@ohos/barchart';
  static readonly ROUTER_PATH_CUSTOM_TAB_BAR: string = '@ohos/custom-tabbar';
  ...
}
```

4. 在主模块中注册路由，并添加页面信息，详细代码请参考[FunctionalScenes.ets](../functionalscenes/src/main/ets/FunctionalScenes.ets)。

```typescript
...
@Consume('pageStack') pageStack: NavPathStack;
@State listData: ListData[] = [
  new ListData($r("app.media.bar_chart_top"), 'MpChart图表实现', RouterNameConstants.ROUTER_NAME_BAR_CHAT, 1, true, '30%', RouterPathConstants.ROUTER_PATH_BAR_CHAT),
  new ListData($r("app.media.address_exchange"), '地址交换动画', RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE, 2, true, '25%', RouterPathConstants.ROUTER_PATH_ADDRESS_EXCHANGE),
  ...
]
...
aboutToAppear(): void {
  DynamicsRouter.createRouter(this.pageStack);
}
```

5. 在需要加载时将页面放入路由栈，详细代码请参考[FunctionalScenes.ets](../functionalscenes/src/main/ets/FunctionalScenes.ets)。

```typescript
@Builder
MethodPoints(listData: ListData) {
   Column() {
   ...
  .onClick(() => {
    let router: RouterModel = new RouterModel();
    router.path = listData.path;
    router.routerName = listData.routerName;
    router.param = listData.param;
    DynamicsRouter.push(router);
  })
}
```

6. 在子模块中添加动态路由的依赖，此处以addressexchange为例，详细代码可参考[oh-package.json](../addressexchange/oh-package.json5)。

```
...
"dependencies": {
  "@ohos/base": "file:../../common/utils",
  // 动态路由模块，用于配置动态路由
  "@ohos/dynamicsRouter": "file:../../feature/dynamicsrouter"
}
```

7. 在子模块中添加动态加载页面组件的接口harInit，此处以addressexchange为例，详细代码可参考[Index.ets](../addressexchange/Index.ets)。

```typescript
export function harInit() {
  import('./src/main/ets/view/AddressExchangeView');
}
```

8. 在子模块中添加动态创建组件的方法，并注册到动态路由中，此处以addressexchange为例，详细代码可参考[AddressExchangeView.ets](../addressexchange/src/main/ets/view/AddressExchangeView.ets)。

```typescript
...
@Builder
export function createDynamicsImportView(): void {
  AddressExchangeView();
}
        
let builderName = RouterNameConstants.ROUTER_NAME_ADDRESS_EXCHANGE;
if(!DynamicsRouter.getBuilder(builderName)){
  let builder: WrappedBuilder<[object]> = wrapBuilder(createDynamicsImportView);
  DynamicsRouter.registerBuilder(builderName, builder);
}
```

9. 如果5中设置的router.param是非空的，需要给8中的createDynamicsImportView接口添加参数，否则会报错，详细代码请参考[NavigationParameterTransferView](../navigationparametertransfer/src/main/ets/view/NavigationParameterTransferView.ets)。

```typescript
...
@Builder
export function createDynamicsImportView(param: ESObject): void {
  NavigationParameterTransferView();
}
...
```

### 高性能知识点

本示例使用动态import的方式加载模块，只有需要进入页面时才加载对应的模块，减少主页面启动时间和初始化效率，减少内存的占用。

### 工程结构&模块类型

   ```
   dynamicsrouter                                  // har类型
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

[动态路由Sample](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/Navigation/DynamicRouter)