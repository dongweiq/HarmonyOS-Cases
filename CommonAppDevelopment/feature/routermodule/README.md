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

    ```ts
    public static createNavPathStack(router: NavPathStack): void {
      DynamicsRouter.navPathStack = router;
    }
    ```

2. 获取路由

    ```ts
    private static getNavPathStack(): NavPathStack {
      return DynamicsRouter.navPathStack;
    }
    ```

3. 通过builderName，注册WrappedBuilder对象，用于动态创建页面

    ```ts
    private static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
      DynamicsRouter.builderMap.set(builderName, builder);
    }
    ```
   
4. 通过builderName，获取注册的WrappedBuilder对象

    ```ts
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

    ```ts
    public static async push(routerInfo: RouterInfo, param?: string): Promise<void> {
      const pageName: string = routerInfo.pageName;
      const moduleName: string = routerInfo.moduleName;
      let isImportSucceed: boolean = false;
      await import(moduleName).then((result: ESObject) => {
        result.harInit(pageName);
        isImportSucceed = true;
      }, (error: ESObject) => {
        logger.error(LOGGER_TAG, error);
      });
      if (isImportSucceed) {
        const builderName: string = moduleName + "/" + pageName;
        DynamicsRouter.getNavPathStack().pushPath({ name: builderName, param: param });
      }
    }
    ```

6. 注册动态路由跳转的页面信息

    ```ts
    public static registerRouterPage(routerInfo: RouterInfo, wrapBuilder: WrappedBuilder<[object]>) {
      let builderName: string = routerInfo.moduleName + "/" + routerInfo.pageName;
      if (!DynamicsRouter.getBuilder(builderName)) {
        DynamicsRouter.registerBuilder(builderName, wrapBuilder);
      }
    }
    ```

**动态路由的使用**

下面以eventpropagation模块举例说明如何使用动态路由加载子模块页面。

1. 在工程的根目录的build-profile.json5中添加动态路由模块和需要加载的子模块的依赖，详细代码参考[build-profile.json5](../../build-profile.json5)。

    ```
    {
      "app":{
        ...
      }
      "modules":{
        ...
        {
          "name": "eventpropagation",
          "srcPath": "./feature/eventpropagation"
        },
        {
          "name": "routermodule",
          "srcPath": "./feature/routermodule"
        }
        ...
      }
    }
    ```

2. 在主模块中添加动态路由和需要加载的子模块的依赖，详细代码请参考[oh-package.json](../../product/entry/oh-package.json5)。

    ```
    "dependencies": {
      "@ohos/dynamicsrouter": "file:../../feature/routermodule",    
      "@ohos/event-propagation": "file:../../feature/eventpropagation",
      ...
    }
    ```

3. 在主模块中添加动态import变量表达式需要的参数，此处在packages中配置的模块名必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，详细代码请参考[build-profile.json5](../../product/entry/build-profile.json5)。

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

4. 在routermodule模块中添加动态路由跳转的moduleName（模块名）和pageName（页面名），RouterInfo中配置的moduleName必须和[oh-package.json](../../product/entry/oh-package.json5)中配置的名称相同，RouterInfo中添加的pageName是子模块中需要加载的页面，详细代码请参考[RouterInfo.ets](./src/main/ets/constants/RouterInfo.ets)。

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

5. 在主模块中注册路由，并添加页面信息，详细代码请参考[EntryView.ets](../../product/entry/src/main/ets/pages/EntryView.ets)。

    ```ts
    ...
    @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
    @State listData: SceneModuleInfo[] = waterFlowData;
    ...
    aboutToAppear(): void {
      DynamicsRouter.createNavPathStack(this.pageStack);
      ...
    }
    ...
    ```

6. 在主模块的WaterFlowData.ets中，将子模块要加载的页面，添加到列表中，详细代码请参考[WaterFlowData.ets](../../product/entry/src/main/ets/data/WaterFlowData.ets)。

    ```ts
    export const waterFlowData: SceneModuleInfo[] = [
      ...
      new SceneModuleInfo($r("app.media.event_propagation"), '阻塞事件冒泡', RouterInfo.EVENT_TRANSMISSION_SOLUTION, '其他', 1),
      ...
    }
    ```

7. 在需要加载时将页面放入路由栈，详细代码请参考[FunctionalScenes.ets](../functionalscenes/src/main/ets/FunctionalScenes.ets)。

    ```ts
    @Builder
    methodPoints(listData: ListData) {
      Column() {
      ...
        .onClick(() => {
          DynamicsRouter.push(listData.routerInfo, listData.param);
        })
    }
    
    ```

8. 在子模块中添加动态路由的依赖，详细代码可参考[oh-package.json](../eventpropagation/oh-package.json5)。

    ```
    ...
    "dependencies": {
      ...
      "@ohos/dynamicsrouter": "file:../../feature/routermodule"
    }
    ```

9. 在子模块中添加动态加载页面组件的接口harInit，其中pageName和RouterInfo中配置的pageName相同，import()接口中传入的参数，是页面的相对路径。详细代码可参考[Index.ets](../eventpropagation/Index.ets)。
如果模块中有多个页面需要跳转，则需要配置多个pageName和页面路径，并且pageName和页面路径需要一一对应，否则无法跳转到预期中的页面，可参考[barchart模块中的Index.ets](../barchart/Index.ets)文件。

    ```ts
    export function harInit(pageName: string) {
      switch (pageName) {
        case RouterInfo.EVENT_TRANSMISSION_SOLUTION.pageName:
          import('./src/main/ets/view/EventPropagation');
          break;
      }
    }
    ```

10. 在子模块中添加动态创建组件的方法，并注册到动态路由中，详细代码可参考[EventPropagation.ets](../eventpropagation/src/main/ets/view/EventPropagation.ets)。

    ```ts
    ...
    @Builder
    export function getEventPropagation(): void {
      EventPropagation();
    }
    
    DynamicsRouter.registerRouterPage(RouterInfo.EVENT_TRANSMISSION_SOLUTION, wrapBuilder(getEventPropagation));
    ```

11. 如果**7**中设置的router.param是非空的，需要给**10**中的@Buidler接口添加参数，否则会报错，详细代码请参考[NavigationParameterTransferView](../navigationparametertransfer/src/main/ets/view/NavigationParameterTransferView.ets)。

    ```ts
    ...
    @Builder
    export function getNavigationParameterTransferView(param: ESObject): void {
      NavigationParameterTransferView();
    }
    ...
    ```

12. 子模块中的两个页面需要使用动态路由进行跳转时，则不需要执行**6**，即不需要将页面添加到首页数据中。

### 高性能知识点

本示例使用动态import的方式加载模块，只有需要进入页面时才加载对应的模块，减少主页面启动时间和初始化效率，减少内存的占用。

### 工程结构&模块类型

   ```
   routermodule                                  // har类型
   |---constants
   |   |---RouterInfo.ets                        // 路由信息类，用于配置动态路由跳转页面的名称和模块名
   |---router
   |   |---DynamicsRouter.ets                    // 动态路由实现类
   ```

### 模块依赖

**不涉及**

### 参考资料

[动态路由Sample](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/ApplicationModels/DynamicRouter)