# 发布图片评论

### 介绍

本示例将通过发布图片评论场景，介绍如何使用startAbilityForResult接口拉起相机拍照，并获取相机返回的数据。

### 效果图预览

![图片评论](../../product/entry/src/main/resources/base/media/image_comment.gif)

**使用说明**

1. 通过startAbilityForResult接口拉起相机，拍照后获取图片地址。

### 实现思路

1. 创建CommentData类，实现IDataSource接口的对象，用于评论列表使用LazyForEach加载数据。源码参考[CommentModel.ets](./src/main/ets/components/model/CommentModel.ets)。
```ts
export class CommentData extends BasicDataSource {
  // 懒加载数据
  private comments: Array<Comment> = [];

  // TODO：知识点：获取懒加载数据源的数据长度
  totalCount(): number {
    return this.comments.length;
  }

  // 获取指定数据项
  getData(index: number): Comment {
    return this.comments[index];
  }

  // TODO：知识点：存储数据到懒加载数据源中
  pushData(data: Comment): void {
    this.comments.push(data);
    AppStorage.setOrCreate('commentCount', this.totalCount());
    // 在数组头部添加数据
    this.notifyDataAdd(this.comments.length - 1);
  }
}
```

2. 点击下方输入提示框，拉起评论输入弹窗。源码参考[ImageCommentView.ets](./src/main/ets/components/view/ImageCommentView.ets)。

```typescript
Text($r('app.string.text_input_hint'))
  ...
  .onClick(() => {
    if (this.dialogController != null) {
      // 打开评论输入弹窗
      this.dialogController.open();
    }
  })
```

3.在输入弹窗中，输入文字，点击相机按钮，拉起相机，拍照后获得返回的图片地址。源码参考[CameraUtils.ets](./src/main/ets/components/utils/CameraUtils.ets)。

```typescript
Image($r('app.media.camera'))
  ...
  .onClick(async () => {
    ...
    let image: string = await cameraCapture(getContext(this) as common.UIAbilityContext);
    ...
  })
...
export async function cameraCapture(context: common.UIAbilityContext): Promise<string> {
  let result: common.AbilityResult = await context.startAbilityForResult({
    action: Constants.ACTION_PICKER_CAMERA,
    parameters: {
      'supportMultiMode': false,
      'callBundleName': context.abilityInfo.bundleName
    }
  });
  if (result.resultCode === 0) {
    let param: Record<string, Object> | undefined = result.want?.parameters;
    if (param !== undefined) {
      let resourceUri: string = param[Constants.KEY_RESULT_PICKER_CAMERA] as string;
      return resourceUri;
    }
  }
  return "";
}
```

4.点击发布按钮，将评论添加到列表中。

```typescript
Button($r('app.string.publish'))
  ...
  .onClick(() => {
    if (this.controller) {
      this.textInComment = this.text;
      this.imagesInComment = this.selectedImages;
      this.publish();
      this.controller.close();
      this.textInComment = "";
      this.imagesInComment = [];
    }
  })
...
publishComment(): void {
  let comment: Comment = new Comment("Kevin", this.textInComment, $r('app.media.icon'), this.imageInComment, this.getCurrentDate());
  this.commentList.pushData(comment);
}
```

### 工程结构&模块类型

   ```
   imagecomment                                    // har类型
   |---components
   |   |---constants
   |       |---Constants.ets                       // 常量类
   |   |---model
   |       |---CommentModel.ets                    // 评论数据类
   |       |---MockCommentData.ets                 // 生成模拟数据
   |   |---utils
   |       |---CameraUtils.ets                     // 拉起相机工具类
   |   |---view
   |       |---CommentInputDialog.ets              // 输入评论弹窗
   |       |---CommentItemView.ets                 // 单个评论组件
   |       |---ImageCommentView.ets                // 评论列表页
   |       |---ImageListView.ets                   // 评论图片List组件
   ```

### 模块依赖

[@ohos/routermodule(动态路由)](../../feature/routermodule)

### 参考资料

[UIAbilityContext](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-inner-application-uiabilitycontext-0000001774120926#ZH-CN_TOPIC_0000001774120926__uiabilitycontextstartabilityforresult)