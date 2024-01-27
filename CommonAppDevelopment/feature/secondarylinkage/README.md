# 二级联动

### 介绍

本示例主要介绍了[List组件](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-list.md)实现二级联动（Cascading List）的场景。 该场景多用于短视频中拍摄风格的选择、照片编辑时的场景的选择。

### 效果图预览

<img src="../../screenshots/device/SecondaryLinkage.gif" width="200">

**使用说明**：

1. 滑动二级列表侧控件，一级列表随之滚动。
2. 点击一级列表，二级列表随之滚动。

## 实现思路

1. 一二级列表分别绑定不同的Scroller对象，一级列表(tagLists)绑定classifyScroller对象，二级列表绑定scroller对象。
2. 通过循环，构造一二级列表数据。
3. 点击一级列表后，通过一级列表的索引获取二级列表的索引，调用scrollToIndex方法将一二级列表滚动到指定索引值。
4. 滑动二级列表触发组件滚动事件后，获取到列表可视区域第一个item对应的索引值，通过二级列表索引获取一级列表索引，调用scrollToIndex方法将一级列表滚动到指定索引值。

### 高性能知识点

本示例使用了LazyForEach进行数据懒加载，List布局时会根据可视区域按需创建ListItem组件，并在ListItem滑出可视区域外时销毁以降低内存占用。

### 工程结构&模块类型

   ```
   secondarylinkage                                // har
   |---pages
   |   |---DataType.ets                            // 数据类型定义 
   |   |---SecondaryLinkExample.ets                // 二级联动功能实现页面 
   ```

### 模块依赖

**不涉及**

### 参考资料

[LazyForEach详细用法](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/quick-start/arkts-rendering-control-lazyforeach.md)