# 列表编辑实现方案

### 介绍

列表的编辑模式用途十分广泛，常见于待办事项管理、文件管理、备忘录的记录管理等应用场景。在列表的编辑模式下，新增和删除列表项是最基础的功能，其核心是对列表项对应的数据集合进行数据添加和删除。

### 效果图预览

<img src="../../screenshots/device/TodoList.gif" width="300">

**实现步骤**

1. List组件绑定@State修饰的数组变量toDoData。
2. ListItem组件设置左滑动效[swipeAction](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-listitem.md#swipeactionitem10%E5%AF%B9%E8%B1%A1%E8%AF%B4%E6%98%8E)
属性，使得单个ListItem可以进行左右滑动，并显示自定义的UIBuilder。
属性。
3. 触发点击事件新增/删除列表项，更新数组变量toDoData，并同时更新List组件UI(MVVM)，具体可参考代码文件[ToDoList](src/main/ets/pages/ToDoList.ets)。

**使用说明**：

* 点击添加按钮，选择需要添加的待办事项。
* 长按待办事项，点击删除后，被勾选待办事项被删除。
* 左滑单个待办事项，点击删除按钮后，当前待办事项被删除。