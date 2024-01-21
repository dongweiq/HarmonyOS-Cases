# 读Rawfile中部分内容

### 介绍

本示例主要如何读取Rawfile中文本文件部分内容的问题。

**场景**

rawfile路径下存在一个有内容的文本文件rawfile.txt。
界面启动时，把该文件名以、开始位置、读取长度作为参数调用native的GetRawFileContent接口，把读取到的内容显示在界面上。
具体代码可参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)。

**使用说明**：

1. 直接进入页面即可显示