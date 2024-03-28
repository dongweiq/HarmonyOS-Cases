# 自定义日历选择器

### 介绍

本示例介绍通过CustomDialogController类显示自定义日历选择器。

### 效果图预览

![](../../product/entry/src/main/resources/base/media/custom_calendar_picker_dialog.gif)

**使用说明**

1. 加载完成后显示主界面，点当前日期后会弹出日历选择器，选择日期后会关闭弹窗，主页面日期会变成选定的日期，应用退出再进入还是显示上次选择的日期。

### 实现思路

1. 获取当前月和下个月的日期信息。源码参考[GetDate.ets](./src/main/ets/components/GetDate.ets)。
```ts
const SATURDAY = 6 // 日历表上周六对应的序列号，从周日开始算起，取值0~6
export function getMonthDate(specifiedMonth: number, specifiedYear: number) {
  let currentFirstWeekDay: number = 0; // 初始化指定月的第一天是周几
  let currentLastWeekDay: number = 0; // 初始化指定月的最后一天是周几
  let currentAllDay: number[] = []; // 初始化指定月的日期排列数组
  let totalDays = new Date(specifiedYear, specifiedMonth, 0).getDate(); // 初始化指定月总天数
  currentFirstWeekDay = new Date(specifiedYear, specifiedMonth - 1, 1).getDay() // 获取指定月的第一天是周几
  currentLastWeekDay = new Date(specifiedYear, specifiedMonth - 1, totalDays).getDay() // 获取指定月的最后一天是周几
  // 将月份中显示上个月日期的内容置0
  for (let item = 0; item < currentFirstWeekDay; item++) {
    currentAllDay[item] = 0;
  }
  // 将本月日期内容存入数组
  for (let item = 1; item <= totalDays; item++) {
    currentAllDay.push(item);
  }
  // 将月份中显示下个月日期的内容置0
  for (let item = 0; item < SATURDAY - currentLastWeekDay; item++) {
    currentAllDay.push(0);
  }
  return currentAllDay;
}
  ```
2. 通过CustomDialogController类初始化自定义日历弹窗。源码参考[CalendarView.ets](./src/main/ets/view/CalendarView.ets)。
```ts
dialogController: CustomDialogController = new CustomDialogController({
  builder: CustomCalendarPickerDialog({
    currentMonth: this.currentMonth,
    currentDay: this.currentDay,
    currentYear: this.currentYear,
    cancel: this.onCancel
  }),
  alignment: DialogAlignment.Bottom, // 自定义弹窗底端对齐
  customStyle: true // 弹窗样式自定义
})
```
3. 设置自定义日历选择器界面。源码参考[CustomCalendarPickerDialog.ets](./src/main/ets/view/CustomCalendarPickerDialog.ets)。
```ts
// 每个月的日期
List({initialIndex: this.initialIndex}) {
  /**
   * 性能知识点：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
   * 当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
   * 文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2
   */
  LazyForEach(this.contentData, (monthItem: Month) => {
    // 设置ListItemGroup头部组件，显示年份和月份
    ListItemGroup({ header: this.itemHead(monthItem.month) }) {
      ListItem() {
        Stack() {
          Text(monthItem.num.toString())
            .fontSize($r('app.integer.month_text'))
            .fontColor($r('app.color.ohos_id_color_palette_aux8'))
            .opacity(MONTH_OPACITY)
          Grid() {
            // TODO: 高性能知识点: 此处日期固定，使用了ForEach，其他列表数量较多的场景，推荐使用LazyForEach+组件复用+缓存列表项实现
            ForEach(monthItem.days, (day: number) => {
              GridItem() {
                Text(day.toString())
                  .fontSize($r('app.string.ohos_id_text_size_headline'))
                  .fontColor(day < this.currentDay && monthItem.num ===
                  this.currentMonth ? $r('app.color.ohos_id_color_text_secondary') : $r('app.color.ohos_id_color_text_primary'))
              }
              .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
              .backgroundColor(day === this.dateModel.day && monthItem.num ===
              this.dateModel.month ? $r('app.color.ohos_id_color_palette9') : $r('app.color.ohos_id_color_background'))
              .opacity(day === 0 ? 0 : 1) // 将日期数组中为0的都设置为不显示，即不显示上个月和下个月的内容
              // 点击选定的日期后，关闭日历弹窗，显示日期改变为选择的日期
              .onClick(() => {
                if (day >= this.currentDay || monthItem.num > this.currentMonth) {
                  let weekIndex = monthItem.days.indexOf(day) % WEEK_NUMBER; // 将当前日转换成星期显示
                  this.dateModel.day = day;
                  this.dateModel.week = weekIndex;
                  this.dateModel.month = monthItem.num;
                  DataManager.setDate(getContext(this), this.dateModel, () => {});
                  this.controller.close(); // 关闭自定义弹窗
                }
              })
            })
          }
          .backgroundColor($r('app.color.ohos_id_color_background'))
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          // 当前月显示的数组元素个数大于35则显示6行，否则显示5行
          .rowsTemplate(monthItem.days.length > MONTH_NUMBER ? '1fr 1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr 1fr')
          .height(monthItem.days.length > MONTH_NUMBER ? GRID_HEIGHT_L : GRID_HEIGHT_M)
        }
      }
    }
  })
}
```
4. 通过用户首选项实现选择的日期数据持久化。源码参考[DataManager.ets](./src/main/ets/components/DataManager.ets)。
```ts
static setDate(context: Context, dateModel: DateModel, callback: () => void) {
  try {
    // 获取Preferences实例
    let promise = dataPreferences.getPreferences(context, 'date')
    promise.then((object: dataPreferences.Preferences) => {
      try {
        // 将数据写入缓存的Preferences实例中
        let setPromise = object.put('selectedDate', JSON.stringify(dateModel))
        setPromise.then(() => {
          // 将缓存的Preferences实例中的数据异步存储到用户首选项的持久化文件中
          let flushPromise = object.flush()
          flushPromise.then(() => {
            // 创建单个AppStorage的键值对
            AppStorage.setOrCreate<DateModel>('selectedDate', dateModel)
            callback()
          }).catch((err: Error) => {
            callback()
            console.error("LoginMessage: Failed to flush" + err.name + ", message = " + err.message)
          })
        }).catch((err: Error) => {
          callback()
          console.error("LoginMessage: Failed to put selectedDate" + err.name + ", message = " + err.message)
        })
      } catch (err) {
        callback()
        console.error("LoginMessage: Failed to put selectedDate" + err.name + ", message = " + err.message)
      }
    }).catch((err: Error) => {
      callback()
      console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
    })
  } catch (err) {
    callback()
    console.error("LoginMessage: Failed to get preferences" + err.name + ", message = " + err.message)
  }
}
```
### 高性能知识点

本示例使用了LazyForEach进行数据懒加载，List布局时会根据可视区域按需创建ListItem组件，并在ListItem滑出可视区域外时销毁以降低内存占用。
[LazyForEach：数据懒加载](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2)

### 工程结构&模块类型

   ```
   customcalendarpickerdialog                      // har类型
   |---components
   |   |---DataManager.ets                         // 持久化方法
   |   |---DateModel.ets                           // 数据类型定义
   |   |---GetDate.ets                             // 获取日期信息
   |   |---MonthDataSource.ets                     // 数据类型定义
   |---view
   |   |---CustomCalendarPickerDialog.ets          // 视图层-自定义日历
   |   |---CalendarView.ets                        // 视图层-场景主页面
   ```

### 模块依赖

本实例依赖common模块来实现[资源](../../common/utils/src/main/resources/base/element)的调用。

### 参考资料

[自定义弹窗](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/ts-methods-custom-dialog-box-0000001477981237-V2)

[LazyForEach：数据懒加载](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-rendering-control-lazyforeach-0000001524417213-V2)

[通过用户首选项实现数据持久化](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-persistence-by-preferences-0000001774120070)
