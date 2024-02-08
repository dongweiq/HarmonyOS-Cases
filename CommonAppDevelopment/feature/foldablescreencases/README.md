# 折叠屏音乐播放器方案

### 介绍

本示例介绍使用ArkUI中的容器组件FolderStack在折叠屏设备中实现音乐播放器场景。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/music_player.gif" width="200">

**使用说明**

1. 播放器预加载了歌曲，支持播放、暂停、重新播放，在折叠屏上，支持横屏悬停态下的组件自适应动态变更。

### 实现思路

1. 采用MVVM模式进行架构设计，目录结构中区分展示层、模型层、控制层，展示层通过控制层与模型层沟通，展示层的状态数据与控制层进行双向绑定，模型层的变更通过回调形式通知给控制层，并最终作用于展示层。

2. 在可折叠设备上使用FolderStack组件作为容器组件，承载播放器的所有功能组件，在半折叠态上，使需要移动到上屏的子组件产生相应的动态效果。
```typescript
// TODO：知识点：FolderStack继承于Stack控件，通过upperItems字段识别指定id的组件，自动避让折叠屏折痕区后移到上半屏
FolderStack({ upperItems: [CommonConstants.FOLDER_STACK_UP_COMP_ID] }) {
    MusicPlayerInfoComp({ musicModel: this.musicModel, curFoldStatus: this.curFoldStatus })
        .id(CommonConstants.FOLDER_STACK_UP_COMP_ID)
    MusicPlayerCtrlComp({ musicModel: this.musicModel })
}
```

3. 在需要移动到上屏的子组件上添加属性动效，当组件属性发生变更时，达成动态展示效果。
```typescript
Image(this.musicModel.cover)
  .width(this.curImgSize)
  .height(this.curImgSize)
  .margin(20)
  .animation(this.attrAniCfg)
  .interpolation(ImageInterpolation.High)
  .draggable(false)
```

4. 折叠屏设备上，依赖display的屏幕状态事件，监听屏幕折叠状态变更，通过对折叠状态的分析，更新UI属性。
```typescript
display.on('foldStatusChange', (curFoldStatus: display.FoldStatus) => {
    this.curFoldStatus = curFoldStatus;
    this.windowModel.updateMainWinPreferredOrientation(curFoldStatus);
})
```

### 高性能知识点

暂无

### 工程结构&模块类型

   ```
   foldablescreencases                  // har类型
   |---common
   |   |---constants
   |   |    |---CommonConstants.ets     // 通用常量
   |   |    |---SysCapConstants.ets     // 系统能力常量
   |---components
   |   |---MusicPlayerCtrlComp.ets      // 自定义组件-音乐播放器控制栏
   |   |---MusicPlayerInfoComp.ets      // 自定义组件-音乐播放器歌曲详情展示
   |---model
   |   |---AVPlayerModel.ets            // 模型层-音频播放管理器 
   |   |---MusicModel.ets               // 模型层-音乐歌曲数据模型 
   |   |---SysCapModel.ets              // 模型层-系统能力管理器 
   |   |---WindowModel.ets              // 模型层-窗口管理器 
   |---pages
   |   |---MusicPlayerPage.ets          // 展示层-音乐播放器 
   |---viewmodel
   |   |---MusicPlayerViewModel.ets     // 控制层-音乐播放器控制器
   ```

### 模块依赖

依赖本地的utils模块

### 参考资料

- [FolderStack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-folderstack-0000001821000897)
- [属性动画](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-animatorproperty-0000001774281022)
- [AVPlayer](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/using-avplayer-for-playback-0000001820880265)
- [状态管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/3_2_u72b6_u6001_u7ba1_u7406-0000001774119938)