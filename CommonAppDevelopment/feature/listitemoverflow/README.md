# 元素超出List区域

### 介绍

本示例介绍在List组件内实现子组件超出容器边缘的布局样式的实现方法。

List组件clip属性默认为true，超出容器边缘的子组件会按照List的布局范围被裁剪。为此，可以在List组件内部添加一个占位的ListItem，以达到预期的布局效果。List占满整个窗口或者不可滚动的情况下，也可以在List外占位，同时设置List的clip属性为false达成同样的效果。

该布局效果多用于头像、列表子项标题等元素的突出显示。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/listitem_overflow.jpg)

**使用说明**：

* 上下滑动屏幕，可以查看整个列表。

### 实现步骤

1. 通过设置负的margin值，移动组件位置，使其超出父组件范围。
```typescript
Image($r("app.media.io_user_portrait"))
  .width(80)
  .height(80)
  .margin({ top: -50, left: 15 })
```

2. 在List内部使用ListItem占位，包住超出的区域。
```typescript
List() {
  ListItem().height(40).selectable(false) // 占位组件
  ListItem() { // 需要超出范围的组件
  Image($r("app.media.io_user_portrait"))
    .width(80)
    .height(80)
    .margin({ top: -50, left: 15 })
  }
  ...
}
```

## 实现步骤（另一种方式）

1. 通过设置负的margin值，移动组件位置，使其超出父组件范围。
```typescript
Image($r("app.media.io_user_portrait"))
  .width(80)
  .height(80)
  .margin({ top: -50, left: 15 })
```

2. 在List组件外部使用Row占位，同时设置List.clip(false)，允许滚动时上下溢出List组件的区域。
```typescript
Row().height(60) // 占位组件
List() {
  ListItem() { // 需要超出范围的组件
  Image($r("app.media.io_user_portrait"))
    .width(80)
    .height(80)
    .margin({ top: -50, left: 15 })
  }
  ...
}.clip(false)
```

### 高性能知识点

不涉及

### 工程结构&模块类型

   ```
   listitemoverflow                                // har类型
   |---AboutMe.ets                                 // 页面布局实现页面
   ```

### 模块依赖

[@ohos/routermodule(动态路由)](../../feature/routermodule)

### 参考资料

[List](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-list-0000001774121286#ZH-CN_TOPIC_0000001774121286__stickystyle9%E6%9E%9A%E4%B8%BE%E8%AF%B4%E6%98%8E)

[clip](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-sharp-clipping-0000001821000801#ZH-CN_TOPIC_0000001821000801__clip)
