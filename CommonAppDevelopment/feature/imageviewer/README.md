# 图片预览器方案

### 介绍

本模块基于Image组件实现了简单的图片预览功能。具体功能如下：

1. 左右滑动切换图片
2. 双指捏合缩放图片大小
3. 双击图片进行图片的大小切换
4. 图片在放大模式下，滑动图片查看图片的对应位置

### 效果图预览

![demo](../../screenshots/device/ImageViewer.gif)

### 依赖

无

### 实现方案

关键点：

1. 使用Swiper来实现左右滑动切换图片的效果
1. image组件的objectFit属性设置为Contain以保证图片缩放过程中的宽高比
1. 通过对image组件的宽高、位置控制来实现图片的缩放与移动

### 开发套件

ide：Build Version: 4.1.3.300, built on November 19, 2023

sdk：4.1.2.1

测试设备：Mate60Pro

测试设备系统版本：2.1.3.5（Canary2）

### 参考资料

1. [image](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-basic-components-image-0000001580026342-V2?catalogVersion=V2)
2. [gesture](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/3_3_u624b_u52bf_u5904_u7406-0000001580185734-V2v)
3. [swiper](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/ts-container-swiper-0000001630306301-V2)
4. [window](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/js-apis-window-0000001630146157-V2)