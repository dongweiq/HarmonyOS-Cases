
# Web获取相机拍照图片案例

### 介绍

本示例介绍如何在HTML页面中拉起原生相机进行拍照，并获取返回的图片。

### 效果预览图

![](../../product/entry/src/main/resources/base/media/web_get_camera_image.gif)

**使用说明**
1. 点击HTML页面中的选择文件按钮，拉起原生相机进行拍照。
2. 完成拍照后，将图片在HTML的img标签中显示。

### 实现思路
1. 添加Web组件，设置[onShowFileSelector](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-web-0000001774281246#ZH-CN_TOPIC_0000001774281246__onshowfileselector9)属性，接收HTML页面中input的点击事件。在onShowFileSelector中调用invokeCamera接口，拉起原生相机进行拍照，并通过callback回调方法获得照片的uri。然后将uri放在[FileSelectorResult](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-web-0000001774281246#ZH-CN_TOPIC_0000001774281246__fileselectorresult9)中，通过event参数返回给HTML页面。源码参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)。

```ts
...
Web({ src: $rawfile(LOCAL_HTML_PATH), controller: this.controller })
  .onShowFileSelector((event: FileResult) => { 
    this.invokeCamera(((uri: string) => {
      event?.result.handleFileList([uri]);
    }))
    return true;
  })
...
```

2. 实现invokeCamera接口，拉起原生相机，并通过callback回调方法返回拍照结果。源码参考[MainPage.ets](./src/main/ets/components/mainpage/MainPage.ets)。

```ts
invokeCamera(callback: (uri: string) => void) {
  const context = getContext(this) as common.UIAbilityContext;
  let want: Want = {
    action: ACTION_IMAGE_CAPTURE,
    parameters: {
      "callBundleName": context.abilityInfo.bundleName,
    }
  };
  let result: (error: BusinessError, data: common.AbilityResult) => void = (error: BusinessError, data: common.AbilityResult) => {
    if (error && error.code !== 0) {
      logger.error(`${TAG_CAMERA_ERROR} ${JSON.stringify(error.message)}`);
      return;
    }
    let resultUri: string = data.want?.parameters?.resourceUri as string;
    if (callback && resultUri) {
      callback(resultUri);
    }
  }
  context.startAbilityForResult(want, result);
}
```
3. 在HTML页面中添加input标签，并在onChange属性中添加js方法，通过dom tree返回的描述事件相关信息的event对象接收ArkTS返回的照片，并显示在img标签上。源码参考[camera.html](./src/main/resources/rawfile/camera.html)。
```html
<script>
  function showPic() {
    let event = this.event;
    let tFile = event ? event.target.files : [];
    if (tFile === 0) {
      document.getElementById('image_preview').style.display = 'block';
      document.getElementById('image_preview').innerHTML = "未选择图片";
      return
    }
    document.getElementById('image').setAttribute('src', URL.createObjectURL(tFile[0]));
    document.getElementById('image_preview').style.display = 'block';
    document.getElementById('image').style.display = 'block';
  }
</script>
<input ref="camera" type="file" id="upload" name="upload" accept="image/*" capture="upload" onchange="showPic()" />
<p id="image_preview">图片预览</p>
<img id="image">
```
### 工程结构&模块类型

   ```
   webgetcameraimage                                           // har类型
   |---mainpage
   |   |---MainPage.ets                                       // ArkTS页面
   |---rawfile
   |   |---camera.html                                        // HTML页面
   ```

### 模块依赖

[**utils**](../../common/utils)

[**routermodule**](../routermodule)

### 参考资料

[Web组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-web-0000001774281246#ZH-CN_TOPIC_0000001774281246__onshowfileselector9)