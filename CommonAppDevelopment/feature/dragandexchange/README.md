# Grid和List内拖拽交换子组件位置

### 介绍

本示例分别通过onItemDrop()和onDrop()回调，实现子组件在Grid和List中的子组件位置交换。

### 效果图预览

![demo](../../product/entry/src/main/resources/base/media/drag_and_exchange.gif)

**使用说明：**

1. 拖拽Grid中子组件，到目标Grid子组件位置，进行两者位置互换。
2. 拖拽List中子组件，到目标List子组件位置，进行两者位置互换。

### 实现思路

1. 在Grid组件中，通过editMode()打开编辑模式、通过onItemDragStart()指定拖拽时样式、通过onItemDrop()指定拖拽释放时的行为。源码参考[GridSceneView.ets](./src/main/ets/view/GridSceneView.ets)。

   ```ts
   Grid() { ... }
   .editMode(true) // 设置Grid进入编辑模式
   .onItemDragStart((event: ItemDragInfo, itemIndex: number) => { // 设置拖拽过程中显示的图形
     this.movedItem = this.appInfoList[itemIndex]; // 记录原位置子组件信息
     return this.itemWhileDrag(); 
   })
   .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => { // 拖拽释放时，触发回调
     // isSuccess=false时，说明drop的位置在grid外部；insertIndex > length时，说明有新增元素的事件发生
     if (isSuccess && insertIndex < this.appInfoList.length) {
       this.changeIndex(itemIndex, insertIndex); // 互换子组件index值
     }
   })
   ```

   

2. 在List组件中，通过ListItem的onDragStart()方法指定拖拽开始时的行为，通过List的onTouch()指定拖拽释放时的行为。源码参考[ListSceneView.ets](./src/main/ets/view/ListSceneView.ets)。

   ```ts
   List({ space: 20 }) {
     ForEach(this.appInfoList, (item: AppInfo, index) => {
       ListItem() { ... }
       .onDragStart(() => {
         item.visible = false; // 拖拽时，设置子组件原位置图标不可见
       })
       .onTouch((event: TouchEvent) => { // 拖拽释放时，记录目标位置子组件index值
         if (event.type === TouchType.Down) {
           this.dragIndex = index;
         }
       })
     })
   }
   .onDrop((event: DragEvent, extraParams: string) => {
     let jsonString: JsonObjType = JSON.parse(extraParams) as JsonObjType; // 通过参数extraParams获取原位置子组件index值
     this.changeIndex(this.dragIndex, jsonString.insertIndex); // 互换子组件index值
     this.appInfoList[jsonString.insertIndex].visible = true; // 完成互换后，设置子组件原位置图标不可见
   })
   ```

   

### 高性能知识点

**不涉及**

### 模块依赖

**不涉及**

### 工程结构&模块类型

```
dragandexchange                  // har类型               
|---pages                                       
|---|---Launcher.ets             // 页面层-方案主页面
|---view                                        
|---|---GridSceneView.ets        // 视图层-Grid拖拽页面             
|---|---ListSceneView.ets        // 视图层-List拖拽页面  
|---model                                     
|---|---AppInfo.ets              // 模型层-App信息模型  
```

### 参考资料

1. [创建网格（Grid/GridItem）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-layout-development-create-grid-0000001820999753)
2. [List](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-list-0000001774121286)