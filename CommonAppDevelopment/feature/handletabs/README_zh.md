# Tab组件实现增删Tab标签方案

### 介绍

本示例介绍使用了[Tab组件](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-tabs.md)实现自定义增删Tab页签的功能。该场景多用于浏览器等场景。

### 效果图预览

<img src="../../screenshots/device/HandleTabs.gif" width="200">

**使用说明**：

1. 通过点击右上角新增按钮，新增Tab页面。
2. 点击删除按钮，删除当前Tab页面。

## 实现思路

本例涉及的关键特性以及实现方案如下：

- 通过@Builder自定义封装一个导航页签栏，并通过ForEach完成对Tabs组件的内容页和导航页签栏的动态渲染。
- 通过TabsController的changeIndex可实现页面的跳转，传入的index是数组中对应的索引值。
- 页签的增加通过数组的push方法，增加数组元素。
- 删除页签通过通过删除页面对应数组的索引值处的数据完成，删除后页面跳转位置根据业务逻辑要求确定跳转页面对应的索引值。

### 高性能知识点

本示例使用了ForEach进行数据懒加载，ForEach第三个入参keyGenerator唯一时，动态修改ForEach时，可降低渲染开销。

### 工程结构&模块类型

   ```
   handletabs                                      // har包
   |---model
   |   |---constantsData.ets                       // 定义常量数据
   |---pages                        
   |   |---HandleTabs.ets                          // 增删tab页签功能实现页面
   ```

### 模块依赖

**不涉及**

### 参考资料

[ForEach使用说明](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/quick-start/arkts-rendering-control-foreach.md)

[Tabs组件使用说明](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-tabs.md)
