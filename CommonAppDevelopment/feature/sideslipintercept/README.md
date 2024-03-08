 # 侧滑返回事件拦截案例

### 介绍

  在编辑场景中，存在用户误触返回，导致内容未保存就退出编辑页的现象;
  本示例介绍使用NavDestination组件的onBackPressed回调对返回事件进行拦截，提示用户保存编辑内容，并使用preferences实例持久化保存内容。

### 效果预览图

 <img src="../../product/entry/src/main/resources/base/media/side_slip_Intercept.gif" width="300">

**使用说明**
1. 编辑状态侧滑返回弹出弹窗提醒用户是否保存。
2. 点击弹窗空白区域，弹窗消失，继续编辑。
3. 点击保存按钮，返回主页，保存用户编辑的数据，再次进入编辑页可在上次编辑的基础上再次编辑。

### 实现思路
1. 侧滑后弹出弹窗提示用户是否保存。 源码参考[MainPage.ets](src/main/ets/components/MainPage.ets)。

  ```ts
  // 提示弹窗,
  promptAction.showDialog({
      message: $r('app.string.edit_prompt'),
      alignment: DialogAlignment.Center,
      buttons: [
        {
          text: $r('app.string.unsave_edit'),
          color: $r('app.color.button_text_color')
        },
        {
          text: $r('app.string.save_edit'),
          color: $r('app.color.button_text_color')
        }
      ]
    })
  ```

2. 点击保存按钮，退出编辑页，通过用户首选项preferences实例持久化保存用户编辑的数据。源码参考[MainPage.ets](src/main/ets/components/MainPage.ets)。

  ```ts
  if (data.index === 0) {
        // 返回到主页面
          this.homePageStack.pop(true);
      }
      // 点击保存按钮，保存编辑退出应用
      if (data.index === 1) {
        let preferences: dataPreferences.Preferences | null = null;
        dataPreferences.getPreferences(this.context, 'myStore', (err: BusinessError, val: dataPreferences.Preferences) => {
          preferences = val;
          // 订阅数据变更需要指定observer作为回调方法
          let observer = (key: string) => {
          }
          preferences.on('change', observer);
          // TODO：知识点：触发返回后点击保存通过preferences.put()方法将数据写入到preferences实例中，持久化存储数据
          preferences.put('startup', this.text, (err: BusinessError) => {
            // 数据持久化
            if (preferences !== null) {
              preferences.flush((err: BusinessError) => {
                if (err) {
                  return;
                }
              })
            }
          })
        })
        // 返回到主页面
        this.homePageStack.pop(true);
      }
  ```

3. 重新打开应用，通过preferences实例的getSync方法读取存储的数据。源码参考[MainPage.ets](src/main/ets/components/MainPage.ets)。

  ```ts
  aboutToAppear() {
  let preferences: dataPreferences.Preferences | null = null;
  dataPreferences.getPreferences(this.context, 'myStore', (err: BusinessError, val: dataPreferences.Preferences) => {
    preferences = val;
    // 读取数据并同步到text
    const value: dataPreferences.ValueType = preferences.getSync('startup', this.text);
    this.text = value.toString()
  })
}
  ```


### 高性能知识点

**不涉及**

### 工程结构&模块类型

   ```
   sideslipintercept                                   // har类型
   |---mainpage
   |   |---Mainpage.ets                                // 视图层-组件页面 
   ```

### 模块依赖

本场景依赖了路由模块来[注册路由](../routermodule/src/main/ets/router/DynamicsRouter.ets)。

### 参考资料

[navigation](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation-0000001821000861)

[NavDestination](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navdestination-0000001774280918)

[@ohos.data.preferences (用户首选项)](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V2/js-apis-data-preferences-0000001580026194-V2)
