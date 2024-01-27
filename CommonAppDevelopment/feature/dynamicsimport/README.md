# readme模板

### 介绍

本示例介绍如何使用动态import加载模块，通过类似Java的反射机制，使应用可以按需加载模块。

### 效果图预览



**使用说明**

1. 在HAR中实现商品列表页面，并在HAP中通过动态import的方式加载。
2. 在HAR中动态加载utils模块，并打印商品的点击日志。

### 实现思路

1. 创建LoggerUtil文件，实现loggerInfo接口，并通过动态加载的方式，加载utils模块。源码参考[LoggerUtil.ets](./src/main/ets/utils/LoggerUtil.ets)
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
2. 在商品GridItem的点击事件中调用loggerInfo方法打印日志。源码参考[GoodsGridView.ets](./src/main/ets/view/GoodsGridView.ets)
```ts
  ...
  GridItem() {
    this.buildGridItemView(item);
  }.onClick(() => {
    loggerInfo(`${item.title}`);
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

**不涉及**

### 参考资料

