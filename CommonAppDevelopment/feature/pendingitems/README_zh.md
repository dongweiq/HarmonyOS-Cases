# 列表编辑实现

### 介绍

本示例介绍用过使用[ListItem](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-listitem.md#swipeactionitem10%E5%AF%B9%E8%B1%A1%E8%AF%B4%E6%98%8E)组件属性swipeAction实现列表左滑编辑效果的功能。
该场景多用于待办事项管理、文件管理、备忘录的记录管理等。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/todo_list.gif" width="300">

**使用说明**：

* 点击添加按钮，选择需要添加的待办事项。
* 长按待办事项，点击删除后，被勾选待办事项被删除。
* 左滑单个待办事项，点击删除按钮后，当前待办事项被删除。

## 实现步骤

1. List组件绑定@State修饰的数组变量toDoData。
2. ListItem组件设置左滑动效[swipeAction](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-listitem.md#swipeactionitem10%E5%AF%B9%E8%B1%A1%E8%AF%B4%E6%98%8E)
属性，使得单个ListItem可以进行左右滑动，并显示自定义的UIBuilder。
属性。
3. 触发点击事件新增/删除列表项，更新数组变量toDoData，并同时更新List组件UI(MVVM)，具体可参考代码文件[ToDoList](src/main/ets/pages/ToDoList.ets)。
### 高性能知识点

不涉及

### 工程结构&模块类型

   ```
   pendingitems                                    // har
   |---model
   |   |---ToDo.ets                                // TODO类定义
   |---pages
   |   |---ToDoList.ets                            // 列表项功能增删实现页面
   |   |---ToDoListItem.ets                        // 列表项页面
   ```

### 模块依赖

**不涉及**

### 参考资料

[ListItem](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/arkui-ts/ts-container-listitem.md#swipeactionitem10%E5%AF%B9%E8%B1%A1%E8%AF%B4%E6%98%8E)
