# 图片预览器方案

### 介绍

<<<<<<< HEAD:CommonAppDevelopment/feature/imageviewer/README_zh.md
图片预览在应用开发中是一种常见场景，在诸如QQ、微信、微博等应用中均被广泛使用。本模块基于Image组件实现了简单的图片预览功能。

**使用说明：**
=======
本模块基于Image组件实现了简单的图片预览功能。具体功能如下：
>>>>>>> 7179dad827d24ae2e35681f39e69e96eb6672d83:CommonAppDevelopment/feature/imageviewer/README.md

1. 左右滑动切换图片
2. 双指捏合缩放图片大小
3. 双击图片进行图片的大小切换
4. 图片在放大模式下，滑动图片查看图片的对应位置

### 效果图预览

![demo](../../screenshots/device/ImageViewer.gif)

### 实现思路

1. 使用Swiper来实现左右滑动切换图片的效果
1. image组件的objectFit属性设置为Contain以保证图片缩放过程中的宽高比
1. 通过对image组件的宽高、位置控制来实现图片的缩放与移动

#### 高性能知识点

**不涉及**

### 模块依赖

**不涉及**

### 工程结构&模块类型

```
imageviewer                                     // har类型
|---constants                                   // 常量
|---model                                       // 模型层-方案中用到的各种数据模型
|---view                                        // 视图层-图片预览方案涉及的主要组件
|---|---ImageViewerView.ets                     // 视图层-入口
|---|---ImageContentView.ets                    // 视图层-图片预览方案的主要承载组件
```

### 参考资料

1. [image](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-basic-components-image-0000001580026342-V2?catalogVersion=V2)
2. [gesture](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/3_3_u624b_u52bf_u5904_u7406-0000001580185734-V2v)
3. [swiper](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-container-swiper-0000001630306301-V2)
4. [window](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/js-apis-window-0000001630146157-V2)