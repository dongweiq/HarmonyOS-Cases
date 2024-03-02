# 大文件拷贝案例

### 介绍

文件拷贝是应用开发中的一个常见场景，通常有两种方式，一是直接读写文件的全部内容，二是使用buffer多次读写。前者的优点在于使用简单，但是在大文件场景下，内存占用较高，影响应用性能；后者的优点在于内存占用较小，但是编程稍显复杂。本例将展示如何使用buffer来将大文件的rawfile复制到应用沙箱。

### 效果图预览

![big_file_copy](../../product/entry/src/main/resources/base/media/big_file_copy.gif)

**使用说明**

1. 点击Start Copy按钮开始复制
2. 当复制进度达到100%之后，点击Preview按钮进行文件的预览，以验证文件复制的正确性
3. 如果要反复验证本场景，请在复制完成之后，点击Reset按钮，重置进度，再进行后续验证

### 实现思路

1. 根据rawfile文件名获取其所属hap包的RawFileDescriptor，其内部包含真正rawfile文件的长度、在hap包中的偏移量，hap包的fd
    ```typescript
    let data: resourceManager.RawFileDescriptor = this.context.resourceManager.getRawFdSync(this.fileName);
    ```
1. 打开即将写入的目标文件
   ```typescript
   let targetPath: string = this.context.filesDir + "/" + this.fileName;
   let destFile: fs.File = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
   ```
1. 创建buffer，用于读写文件内容
   ```typescript
   let buffSize: number = BigFileCopyConstants.BUFF_SIZE;
   let buffer: ArrayBuffer = new ArrayBuffer(buffSize);
   ```
1. 使用buffer进行文件内容的循环读写，只要实际读入buffer的内容长度不为0，就表示文件内容没有读取完毕，就将读到的内容写入目标文件。注意，这里使用了buffSize来控制想要读取内容的长度，因此需要注意在循环体内对其进行更新
   ```typescript
    let off: number = 0; // 记录读取位置的偏移（相较于文件起始偏移）
    let len: number = 0; // 本次读取内容的实际长度
    let readedLen: number = 0; // 记录已读文件长度
    while (len = fs.readSync(data.fd, buffer, { offset: data.offset + off, length: buffSize })) {
      readedLen += len;
      fs.writeSync(destFile.fd, buffer, { offset: off, length: len });
      off = off + len;
      if ((data.length - readedLen) < buffSize) {
        buffSize = data.length - readedLen;
      }
    }
   ```
1. 因为复制的是图片文件，复制完毕之后使用Image组件加载该图片进行显示，以验证复制过程的正确性
    ```typescript
    Image(BigFileCopyConstants.SANDBOX_PREFIX + this.targetFilePath)
    ```

### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   bigfilecopy                                        // har类型
   |---constants
   |    |---BigFileCopyConstants                      // 常量
   |---view
   |    |---BigFileCopyView.ets                       // 视图层-文件复制页面
   ```

### 模块依赖

1. [路由模块](../routermodule)：供entry模块实现路由导航

### 参考资料

1. [资源分类与访问](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/resource-categories-and-access-0000001774119914#ZH-CN_TOPIC_0000001774119914__%E8%B5%84%E6%BA%90%E5%88%86%E7%B1%BB)
1. [resourceManager](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-resource-manager-0000001774281590)