# readme模板

### 介绍

本示例介绍使用ArkUI[WaterFlow](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-container-waterflow-0000001582933637-V2)组件和[LazyForEach](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2)实现瀑布流场景。该场景多用于购物、资讯类应用。

### 效果图预览

<img src="./screenshots/device/FunctionalScenes.gif" width="200">

**使用说明**

1. 加载完成后显示整个列表，超过一屏时可以上下滑动。

### 实现思路

1. 创建WaterFlowDataSource类，实现IDataSource接口的对象，用于WaterFlow和LazyForEach加载数据。源码参考[WaterFlowDataSource.ets](./feature/functionalscenes/src/main/ets/model/WaterFlowDataSource.ets)
```ts
export class WaterFlowDataSource implements IDataSource {
  private dataArray: ListData[] = [];
  private listeners: DataChangeListener[] = [];
  
  constructor(dataArray: ListData[]) {
    for (let i = 0; i < dataArray.length; i++) {
      this.dataArray.push(dataArray[i]);
    }
  }
  
  public getData(index: number): ListData {
    return this.dataArray[index];
  }  
  
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }
  
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }
  ...
  ```
2. 通过@Builder自定义瀑布流列表项组件，作为FlowItem的子组件。源码参考[FunctionalScenes.ets](./feature/functionalscenes/src/main/ets/FunctionalScenes.ets)
```ts
  @Builder
  MethodPoints(listData: ListData) {
    Column() {
      Image(listData.imageSrc)
      ...
    }
  }
  ```
3. 结合父组件传递的数据以及WaterFlow和LazyForEach循环构造出整个列表。源码参考[FunctionalScenes.ets](./feature/functionalscenes/src/main/ets/FunctionalScenes.ets)
```ts
WaterFlow() {
  LazyForEach(this.dataSource, (item: ListData) => {
    FlowItem() {
      this.MethodPoints(item)
    }
  })
}
  ```

### 高性能知识点

本示例使用了LazyForEach进行数据懒加载，WaterFlow布局时会根据可视区域按需创建FlowItem组件，并在FlowItem滑出可视区域外时销毁以降低内存占用。

### 工程结构&模块类型

   ```
   functionalscenes                                // har类型(默认使用har类型，如果使用hsp类型请说明原因)
   |---model
   |   |---ListData.ets                            // 模型层-列表数据模型 
   |   |---WaterFlowDataSource.ets                 // 数据模型层-瀑布流数据控制器 
   |---FunctionalScenes.ets                        // 视图层-场景列表页面
   ```

### 模块依赖

**不涉及**(默认不依赖其他模块，如果依赖其他har或hsp模块请详细说明。)

### 参考资料

[WaterFlow+LazyForEach详细用法可参考性能范例](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/performance/waterflow_optimization.md/)