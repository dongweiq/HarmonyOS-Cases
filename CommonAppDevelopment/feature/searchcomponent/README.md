# 搜索功能实现案例

### 介绍

本示例介绍使用includes方法对数据实现模糊查询

### 效果图预览

<img src="./src/main/resources/base/media/search_component.gif" width="200">

**使用说明**

1. 在首页输入框中输入搜索的内容，下方列表自动根据搜索的内容进行筛选渲染

### 实现思路

1. 通过include方法判读是否存在符合条件的数据。源码参考[SearchComponent.ets](./src/main/ets/components/mainpage/SearchComponent.ets)
```ts
  searchFunc(value: string) {
    let newListData: ListData[] = [];
    if (this.searchListData !== undefined) {
      for (let i = 0; i < this.searchListData.length; i++) {
        // 通过includes对输入的字符进行查询
        if (this.searchListData[i].name.toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchListData[i])
        }
      }
    }
    this.listData = newListData
  }
  ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   SearchComponent                                 // har类型(默认使用har类型，如果使用hsp类型请说明原因)
   |---model
   |   |---ListData.ets                            // 筛选数据模型
   |---SearchComponent.ets                         // 搜索组件
   ```

### 模块依赖

**不涉及**

### 参考资料

[search组件详细用法可参考性能范例](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-basic-components-search-0000001428061740-V2)