# 图片选择和下载保存案例

### 介绍

本示例介绍图片相关场景的使用：包含访问手机相册图片、选择预览图片并显示选择的图片到当前页面，下载并保存网络图片到手机相册或到指定用户目录两个场景。

### 效果图预览
![](../../product/entry/src/main/resources/base/media/photopickandsave.gif)
**使用说明**

1. 从主页通用场景集里选择**图片选择和下载保存**进入首页。  
2. 分两个场景
- 点击“+”进入”访问手机相册图片预览并选择”场景示例。
- 点击上部“下载”按钮进入”下载网络图片到手机相册”场景示例；点击下部“下载”按钮进入”下载文件到指定用户目录”场景示例。

### 实现思路

#### 场景1：访问手机相册图片预览并选择
通过photoViewPicker.select()拉起图库界面，用户可以预览并选择一个或多个文件，即可实现拉起手机相册并进行图片的预览与选择。   

1. 创建文件类型为图片的，并最大预览数量为2的图库实例。

```
async getFileAssetsFromType(){
  const photoSelectOptions = new picker.PhotoSelectOptions(); // 创建图库对象实例
  photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE; // 选择媒体文件类型为Image
  photoSelectOptions.maxSelectNumber = 2; // 选择媒体文件的最大数目
 }
```
2. 通过photoViewPicker.select()接口,通过传入参数PhotoSaveOptions图库对象，获取返回的用户选择的图片信息。
```
  async getFileAssetsFromType(){  
    photoViewPicker.select(photoSelectOptions)
      .then((photoSelectResult) => { 
        this.uris = photoSelectResult.photoUris; // select返回的uri权限是只读权限，需要将uri写入全局变量@State中即可根据结果集中的uri进行读取文件数据操作。
      })
      .catch((err: BusinessError) => {
       console.log('Invoke photoViewPicker.select failed, code is ${err.code},message is ${err.message}');
      })
  }
```

#### 场景2：下载并保存网络图片
1. 通过http中request方法获取在线图片数据。

```ts
http.createHttp()
  .request('https://gitee.com/openharmony/applications_app_samples/raw/master/code/Solutions/Shopping/OrangeShopping/feature/navigationHome/src/main/resources/base/media/product002.png',
    (error: BusinessError, data: http.HttpResponse) => {
      if (error) {
        promptAction.showToast({
          message: $r('app.string.image_request_fail'),
          duration: 2000
        })
        return
      }
      this.transcodePixelMap(data);
      if (data.result instanceof ArrayBuffer) {
        this.imageBuffer = data.result as ArrayBuffer;
      }
    })
```

2. 使用createPixelMap方法将获取到的图片数据转换成pixelmap展示到页面中

```ts
// 将ArrayBuffer类型的图片装换为PixelMap类型
transcodePixelMap(data: http.HttpResponse) {
  let code: http.ResponseCode | number = data.responseCode;
  if (ResponseCode.ResponseCode.OK === code) {
    let imageData: ArrayBuffer = data.result as ArrayBuffer;
    let imageSource: image.ImageSource = image.createImageSource(imageData);

    class tmp {
      height: number = 100;
      width: number = 100;
    };

    let options: Record<string, number | boolean | tmp> = {
      'alphaType': 0, // 透明度
      'editable': false, // 是否可编辑
      'pixelFormat': 3, // 像素格式
      'scaleMode': 1, // 缩略值
      'size': { height: 100, width: 100 }
    }; // 创建图片大小

    imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
      this.image = pixelMap;
      this.isShow = true
    });
  }
}
```

3. 将图片保存到图库或者用户选择的路径 
   
   - 使用getPhotoAccessHelper、createAsset、fs.open、fs.write等接口将数据存到本地图库中
   ```ts
     async saveImage(buffer: ArrayBuffer | string): Promise<void> {
       let context = getContext(this) as common.UIAbilityContext;
       let helper = photoAccessHelper.getPhotoAccessHelper(context);
       let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
       let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
       await fs.write(file.fd, buffer);
       await fs.close(file.fd);
     }
   ```

   - 使用photoViewPicker.save、fs.open、fs.write等接口将数据存到用户选择路径的数据库中
   ```ts
     async pickerSave(buffer: ArrayBuffer | string): Promise<void> {
       const photoSaveOptions = new picker.PhotoSaveOptions(); // 创建文件管理器保存选项实例
       photoSaveOptions.newFileNames = ['PhotoViewPicker ' + new Date().getTime() + 'jpg'] // 保存文件名（可选）
       const photoViewPicker = new picker.PhotoViewPicker;
       photoViewPicker.save(photoSaveOptions)
         .then(async (photoSvaeResult) => {
           console.info('PhotoViewPicker.save successfully,photoSvaeResult uri:' + JSON.stringify(photoSvaeResult));
           let uri = photoSvaeResult[0];
           let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
           await fs.write(file.fd, buffer);
           await fs.close(file.fd);
           promptAction.showToast({
             message: $r('app.string.image_request_success'),
             duration: 2000
           })
         })
     }
   ```

### 高性能知识点

不涉及

### 工程结构&模块类型

   ```
   picturemanage                                   // har类型
   |---src/main/ets/components
   |   |---SelectPictures.ets                      // 场景一：访问手机相册图片预览并选择 
   |   |---SaveNetWorkPictures.ets                 // 场景二：下载网络图片并保存到手机相册或用户选择的文件夹
   |   |---PictureManage.ets                       // 视图层-主页面，三个场景入口
   ```

### 模块依赖
依赖[har包-common库中UX标准](../../common/utils/src/main/resources/base/element)


### 参考资料

[photoViewPicker参考文档](https://docs.openharmony.cn/pages/v3.2/zh-cn/application-dev/reference/apis/js-apis-file-picker.md/#photoviewpicker)