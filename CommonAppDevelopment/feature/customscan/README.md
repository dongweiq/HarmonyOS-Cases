# 折叠屏扫描二维码方案

### 介绍

本示例介绍使用自定义界面扫码能力在折叠屏设备中实现折叠态切换适配。自定义界面扫码使用系统能力customScan，其提供相机流的初始化、启动扫码、识别、停止扫码、释放相机流资源等能力。折叠屏折叠状态通过监听display的foldStatusChange事件实现。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/custom_scan.gif" width="200">

**使用说明**

1. 用户授权相机扫码。
2. 对准二维码即可识别展示，支持多二维码识别。
3. 支持打开相机闪光灯。
4. 折叠态不同，相机流的尺寸也不同，因此折叠态变更时，扫码服务会重新初始化。

### 实现思路

1. 相机权限需要用户授权。
```typescript
// 向用户申请授权
let context = getContext() as common.UIAbilityContext;
let atManager = abilityAccessCtrl.createAtManager();
let grantStatusArr = await atManager.requestPermissionsFromUser(context, [ 'ohos.permission.CAMERA' ]);
const grantStatus = grantStatusArr.authResults[0];
```
源码请参考[CustomScanViewModel.ets](./src/main/ets/viewmodel/CustomScanViewModel.ets)

2. 依赖XComponent展示相机流内容，在加载完相机流后启动相机扫码服务。
```typescript
// TODO：知识点：相机流显示依赖XComponent
XComponent({
  id: CommonConstants.CAMERA_XCOMPONENT_ID,
  type: CommonConstants.CAMERA_XCOMPONENT_TYPE,
  controller: this.cameraSurfaceController
})
  .onLoad(() => {
    // TODO：知识点：customScan依赖XComponent组件的surfaceId，对图像进行扫描
    this.customScanVM.surfaceId = this.cameraSurfaceController.getXComponentSurfaceId();
    // TODO：知识点：XComponent加载完成后，启动相机进行扫码
    this.customScanVM.startCustomScan();
  })
```
源码请参考[CustomScanCameraComp.ets](./src/main/ets/components/CustomScanCameraComp.ets)

3. 二维码识别通过customScan系统能力在启动扫描之后，通过异步任务监控相机图像，对识别到的内容直接返回处理。
```typescript
try {
  const viewControl: customScan.ViewControl = {
    width: this.cameraCompWidth,
    height: this.cameraCompHeight,
    surfaceId: this.surfaceId
  };
  customScan.start(viewControl)
    .then((result: Array<scanBarcode.ScanResult>) => {
      // 处理扫码结果
      this.showScanResult(result);
    })
} catch (error) {
  logger.error('start fail, error: %{public}s ', JSON.stringify(error));
}
```
源码请参考[CustomScanViewModel.ets](./src/main/ets/viewmodel/CustomScanViewModel.ets)

4. 识别到的数据为一个结果数组，每一个结果包括识别到的码源信息和二维码图像所在屏幕的坐标
```typescript
let showMsg: string = '';
// 处理扫码结果
scanResult.forEach((result: scanBarcode.ScanResult) => {
  // 码源信息
  const originalValue: string = result.originalValue;
  // 二维码在屏幕上的位置
  const scanCodeRect: scanBarcode.ScanCodeRect | undefined = result.scanCodeRect;

  if (scanCodeRect) {
    showMsg += `内容: ${originalValue}\n坐标: ${JSON.stringify(scanCodeRect)}\n`;
  }
})
```
源码请参考[CustomScanViewModel.ets](./src/main/ets/viewmodel/CustomScanViewModel.ets)

5. 折叠屏设备上，依赖display的屏幕状态事件，监听屏幕折叠状态变更，通过对折叠状态的分析，更新XComponent尺寸并重新启动扫码服务。
```typescript
display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
  // 同一个状态重复触发不做处理
  if (this.curFoldStatus === curFoldStatus) {
    return;
  }

  // 缓存当前折叠状态
  this.curFoldStatus = curFoldStatus;

  if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED
    || this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
    // 当前没有相机流资源，只更新相机流宽高设置
    if (!this.surfaceId) {
      this.updateCameraCompSize();
      return;
    }

    // 关闭闪光灯
    this.tryCloseFlashLight();
    setTimeout(() => {
      // 释放扫码资源
      this.releaseCustomScan();
      // 重新启动扫码
      this.restartCustomScan();
    }, 10)
  }
})
```
源码请参考[CustomScanViewModel.ets](./src/main/ets/viewmodel/CustomScanViewModel.ets)

### 高性能知识点

不涉及

### 工程结构&模块类型

   ```
   customscan                           // har类型
   |---common
   |   |---constants
   |   |    |---CommonConstants.ets     // 通用常量
   |---components
   |   |---CustomScanCameraComp.ets     // 自定义组件-二维码扫描相机流组件
   |   |---CustomScanCtrlComp.ets       // 自定义组件-二维码扫描控制菜单组件
   |---model
   |   |---PermissionModel.ets          // 模型层-权限控制管理器
   |   |---WindowModel.ets              // 模型层-窗口管理器 
   |---pages
   |   |---CustomScanPage.ets           // 展示层-二维码扫描页面 
   |---viewmodel
   |   |---CustomScanViewModel.ets      // 控制层-二维码扫描控制器
   ```

### 模块依赖

[**utils**](../../common/utils)

### 参考资料

- [自定义界面扫码能力](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-customscan-0000001724022421)
- [属性动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-animatorproperty-0000001774281022)
- [程序访问控制管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-abilityaccessctrl-0000001820880529#ZH-CN_TOPIC_0000001820880529__abilityaccessctrlcreateatmanager)