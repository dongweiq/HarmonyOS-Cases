# 动态import功能实现

### 介绍

在应用开发中，一次性把页面中使用到的模块全部加载，可能会影响到启动速度和初始化效率，并占用较多内存。 本示例将介绍如何使用动态import，实现按需加载模块。例如，HAR中包含复杂的页面，HAP并不需要在主页面创建时就import，而是在特定时间点加载（点击页面上某个按钮时才加载模块）。

### 效果图预览

![动态import页面](../../screenshots/device/DynamicsImport.gif)

**使用说明**

1. 在HAR中动态加载utils模块，在点击商品时打印日志。
2. 在HAR中实现商品列表页面，并在HAP中通过动态import的方式加载。
3. 在HAP中通过间接动态import的方式，使用utils模块中的Logger.info()接口打印日志。

### 实现思路

1. 创建LoggerUtil文件，实现loggerInfo接口，并通过动态加载的方式，加载utils模块，使用Logger.info()接口打印日志。源码参考[LoggerUtil.ets](./src/main/ets/utils/LoggerUtil.ets)

```ts
  let logger: ESObject = null;

  export function loggerInfo(message: String) {
    if (logger) {
      logger.info(message);
    } else {
      import('@ohos/base').then((loggerResult: ESObject) => {
        logger = loggerResult.logger;
        logger.info(message);
      })
    }
  }
  ```

2. 在商品GridItem的点击事件中调用loggerInfo方法打印日志，并通过toast显示动态加载Logger成功。源码参考[GoodsGridView.ets](./src/main/ets/view/GoodsGridView.ets)

```ts
  ...
  GridItem() {
    this.buildGridItemView(item);
  }.onClick(() => {
    loggerInfo(`${item.title}`);
    promptAction.showToast({
      message: DynamicsImportConstants.DYNAMICS_IMPORT_LOGGER_SUCCESS,
      duration: DynamicsImportConstants.TOAST_DURATION
    });
  })
  ...
  ```

3. 在DynamicsImportView中，加载GoodsGridView，将通过@Builder自定义的商品页面export，供HAP或者其他模块使用。源码参考[DynamicsImportView.ets](./src/main/ets/view/DynamicsImportView.ets)

```ts
  @Component
  struct DynamicsImportView {
    build() {
      GoodsListView();
    }
  }
  
  @Builder
  export function createDynamicsImportView(): void {
    DynamicsImportView();
  }
  ```

4. 在DynamicsImportPage的aboutToAppear()接口中，通过动态import的方式加载页面，并使用间接动态import的方式，通过utils模块中的Logger.info()接口打印日志。源码参考[DynamicsImportPage.ets](../../product/entry/src/main/ets/view/DynamicsImportPage.ets)

```ts
    ...
    aboutToAppear(): void {
      import('@ohos/dynamicsimport').then((dynamicsImportResult: ESObject) => {
        this.dynamicsImportPage = dynamicsImportResult.createDynamicsImportView;
        this.isDynamicsImportSucceed = true;
        dynamicsImportResult.loggerInfo(DYNAMICS_IMPORT_SUCCEED);
      });
    }
    
    build() {
      Column() {
        if (this.isDynamicsImportSucceed) {
          this.dynamicsImportPage();
        }
      }
    }
    ...
```

### 高性能知识点

本示例使用动态import加载模块，在模块被调用时才会被加载，减少应用的内存占用和页面加载时间。

### 工程结构&模块类型

   ```
   dynamicsimport    
   |---constants        
   |---|---DynamicsImportConstants.est             // 动态import常量                    
   |---model
   |   |---GoodsModel.ets                          // 模型层-列表数据模型 
   |   |---ProductsData.ets                        // 数据模型层-商品模拟数据
   |---utils
   |---|---LoggerUtil.ets                          // 日志打印工具类
   |---view                        
   |---|---DynamicsImportView.ets                  // 视图层-动态import页面
   |---|---GoodsGridView.ets                       // 视图层-Grid列表页面
   ```

### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)的调用以及[公共组件FunctionDescription](../../common/utils/src/main/ets/FunctionDescription.ets)的引用。

### 参考资料

