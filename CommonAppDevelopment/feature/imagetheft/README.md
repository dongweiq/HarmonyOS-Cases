# 正确配置ImageKnife请求头实现防盗链功能

### 介绍

目前许多网络图片资源有防盗链功能，需要在请求头中设置正确的Referer。本模块使用了第三方库imageknife，通过在请求头中添加Referer来获取防盗链图片功能。同时我们可以设置请求头中的其他参数，比如User-Agent来设置客户端，Origin设置来源，ETag来设置缓存等等。

**使用说明：**

1. 输入需要获取的图片URL和Referer。
2. 点击请求，等待下方出现图片。

### 效果图预览

![demo](../../product/entry/src/main/resources/base/media/image_theft.gif)

### 实现思路

1. 在工程入口导入三方库imageKnife，并且进行初始化，参考[Index.ets](./Index.ets)。

    ```typescript
    // 通过ImageKnifeGlobal.getInstance()获取唯一实例。如果此实例不存在，则将ImageKnife注入到当前context中。
    if (!ImageKnifeGlobal.getInstance().getImageKnife()) {
      const context: Context = getContext();
      if (context) {
        ImageKnife.with(context);
      }
    }
    ```

2. 自定义请求头需要重新封装RequestOption对象，使用addHeader方法配置请求头，load方法设置需要请求的地址，errorholder方法设置请求失败回调，addListener方法设置成功回调等配置，最后在成功/失败回调中的图片赋值给图片组件。参考[ImageTheft.ets](./src/main/ets/view/ImageTheft.ets)。

    ```typescript
    // TODO: 知识点：自定义RequestOption来获取image图片。
    const request = new RequestOption();
    // TODO: 知识点：使用addHeader添加请求头。
    request.addHeader('Referer', ref);
    request.skipMemoryCache(true)
      .diskCacheStrategy(new NONE()) // 取消磁盘缓存
      .errorholder($r('app.media.image_failed'), {
        asyncSuccess: (data: ImageKnifeData) => {
          if (data.isPixelMap()) {
            this.imageKnifeOption.loadSrc = data.drawPixelMap?.imagePixelMap;
          }
        }
      })
      .load(url) // TODO: 知识点：添加请求url。
      .addListener({ // TODO: 知识点：添加请求回调监听器。
        callback: (err: BusinessError | string, data: ImageKnifeData) => {
          if (data.isPixelMap()) {
            if (data.drawPixelMap) {
              // TODO: 知识点：在这里获取到请求返回的图片，将图片赋值给imageKnifeOption.loadSrc。
              this.imageKnifeOption.loadSrc = data.drawPixelMap.imagePixelMap;
            } else {
              this.imageKnifeOption.loadSrc = $r('app.media.image_failed');
            }
          }
          return true;
        }
      })
    ```

3. 在需要请求图片的地方，将步骤2中自定义的RequestOption对象传入imageknife实例的call函数，参考[ImageTheft.ets](./src/main/ets/view/ImageTheft.ets)。

    ```typescript
    const compSize: Size = {
      width: IMAGE_THEFT_IMAGEKNIFE_COMPONENT_WIDTH,
      height: IMAGE_THEFT_IMAGEKNIFE_COMPONENT_HEIGHT
    };
    // (必传)这里setImageViewSize函数必传初始组件大小，因为涉及到图片变换效果都需要适配图像源和组件大小。
    // TODO: 知识点：如果是自适应组件等不确定初始图片宽高的情况，可以通过getInspectorByKey获取，参考https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkui-kit-0000001769732210#section10880155113412。
    request.setImageViewSize(compSize);
    // 最后使用ImageKnife的call函数调用request即可
    const imageKnife: ImageKnife | undefined = ImageKnifeGlobal.getInstance().getImageKnife();
    if (imageKnife !== undefined) {
      // 由于本例需要通过改变请求头刷新图片，并不需要图片缓存，所以设置磁盘Lru缓存数量设置成0张，0字节，正常业务不需要此设置。
      imageKnife.setLruCacheSize(0, 0);
      imageKnife.call(request);
    }
    ```

#### 高性能知识点

**不涉及**

### 模块依赖

1. 本实例依赖common模块来实现[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)。
2. 本实例依赖路由模块来[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。
3. 本实例依赖[@ohos/imageknife](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fimageknife)的2.1.2-rc.6及以上版本。

### 工程结构&模块类型

```
imagetheft                                      // har类型
|---constants                                   
|---|---Constants.ets                           // 存放常量
|---view                                        
|---|---ImageTheft.ets                          // 视图层-获取防盗链图片入口
```

### 参考资料

1. [@ohos/imageknife](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fimageknife)
