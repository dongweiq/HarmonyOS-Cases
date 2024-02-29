# 应用异常处理案例

### 介绍

本示例介绍了通过应用事件打点[hiAppEvent](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/js-apis-hiviewdfx-hiappevent-0000001478341401-V3)获取上一次应用异常信息的方法，主要分为应用崩溃、应用卡死以及系统查杀三种。

### 效果图预览

<img src="../../product/entry/src/main/resources/base/media/application_exception.gif" width="300">

**使用说明**：

1. 点击构建应用崩溃事件，3s之后应用退出，然后打开应用进入应用异常页面，隔1min左右后，显示上次异常退出信息。
2. 点击构建应用卡死事件，需手动退出，然后打开应用进入应用异常页面，隔1min左右后，显示上次异常退出信息。

### 实现思路

1. 构建应用异常。源码参考[ApplicationException.ets](./src/main/ets/view/ApplicationException.ets)
```
 handleOperate(index: number) {
    switch (index) {
      case 0:
      // 在按钮点击函数中构造一个APP_CRASH场景，触发应用崩溃事件
        let result: object = JSON.parse('');
        break;
      case 1:
      // 在按钮点击函数中构造一个APP_FREEZE场景，触发应用卡死事件,500ms之后执行无限循环
        while (true) {
        }
    }
  }
```
2. 应用退出后，进入本页面，等待订阅消息通知，待收到订阅消息后，通过EventSubscription.ets中的onReceive函数，接收到异常信息数据，
   并通过AppStorage.setOrCreate('appEventGroups',异常信息数据)双向绑定异常信息，源码参考代码可参考[EventSubscription.ets](./src/main/ets/model/EventSubscription.ets)
```
import hiAppEvent from '@ohos.hiviewdfx.hiAppEvent';
import { logger } from '@ohos/base';

const TAG: string = 'eventSubscription';

export function eventSubscription() {
  // 添加应用事件观察者方法，可用于订阅应用事件
  hiAppEvent.addWatcher({
    // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
    name: "mst",
    // 开发者可以订阅感兴趣的系统事件，此处是订阅了崩溃事件
    appEventFilters: [
      {
        domain: hiAppEvent.domain.OS,
        names: [hiAppEvent.event.APP_CRASH, hiAppEvent.event.APP_FREEZE]
      }
    ],
    // TODO：知识点：获取事件组信息。开发者可以自行实现订阅实时回调函数，以便对订阅获取到的事件数据进行自定义处理
    onReceive: async (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
      logger.info(TAG, `HiAppEvent onReceive: domain=${domain}`);
      // 获取事件组信息，与ApplicationException文件中的@StorageLink('faultMessage') faultMessage进行双向数据绑定
      AppStorage.setOrCreate('appEventGroups', appEventGroups);
    }
  });
}
```
3. @StorageLink('appEventGroups')接收订阅事件函数传递的事件组信息，调用getFaultMessage函数对信息进行处理，将处理后的信息通过 this.faultDataSource.pushData(message)
   添加到懒加载数据源中，并通过this.faultDataSource.persistenceStorage()执行持久化存储，最后通过使用LazyForEach将数据信息加载到页面上。
   具体源码参考[ApplicationException.ets](./src/main/ets/view/ApplicationException.ets)
```
@Component
struct FaultArea {
  // 懒加载数据源
  @State faultDataSource: FaultDataSource = new FaultDataSource();
  // 双向数据绑定懒加载数据源的数组长度
  @StorageLink('faultDataSourceLength') faultDataSourceLength: number = 0;
  // 双向数据绑定事件组，与AppStorage.setOrCreate进行绑定，此变量发生变化触发getFaultMessage函数
  @StorageLink('appEventGroups') @Watch('getFaultMessage') appEventGroups: Array<hiAppEvent.AppEventGroup> = [];
  @Consume eventIndex: number;

  async aboutToAppear() {
    logger.info(TAG, `aboutToAppear start`);
    // 获取Preferences实例
    PreferencesManager.getPreferences(this.faultDataSource);
  }

  // 获取应用异常信息
  async getFaultMessage() {
    logger.info(TAG, `getAppEventGroups start`);
    if (this.appEventGroups && this.appEventGroups.length > 0) {
      // 遍历事件组
      this.appEventGroups.forEach((eventGroup: hiAppEvent.AppEventGroup) => {
        // 遍历事件对象集合
        eventGroup.appEventInfos.forEach(async (eventInfo: hiAppEvent.AppEventInfo) => {
          let message: string = '';
          message += `HiAppEvent eventInfo.domain=${eventInfo.domain}\n` // 事件领域
            + `HiAppEvent eventInfo.name=${eventInfo.name}\n`  // 事件名称
            + `HiAppEvent eventInfo.eventType=${eventInfo.eventType}\n` // 事件名称
            + `HiAppEvent eventInfo.params.time=${eventInfo.params['time']}\n` // 事件发生的时间
            + `HiAppEvent eventInfo.params.crash_type=${eventInfo.params['crash_type']}\n`
            + `HiAppEvent eventInfo.params.foreground=${eventInfo.params['foreground']}\n`
            + `HiAppEvent eventInfo.params.bundle_version=${eventInfo.params['bundle_version']}\n`
            + `HiAppEvent eventInfo.params.bundle_name=${eventInfo.params['bundle_name']}\n`
            + `HiAppEvent eventInfo.params.exception=${JSON.stringify(eventInfo.params['exception'])}\n`
            + `HiAppEvent eventInfo.params.hilog.size=${eventInfo.params['hilog'].length}\n`;
          // TODO：知识点：将异常信息存储到数组faultMessage当中
          this.faultDataSource.pushData(message);
        })
      })
    }
    // TODO：知识点：持久化存储异常信息集合
    this.faultDataSource.persistenceStorage();
  }

  build() {
    List() {
      // 添加判断，如果异常信息集合的信息条数大于0，遍历异常信息
      if (this.faultDataSourceLength > 0) {
        // 性能：动态加载数据场景可以使用LazyForEach遍历数据。https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3
        LazyForEach(this.faultDataSource, (message: string) => {
          ListItem() {
            Text(message)
              .textAlign(TextAlign.Start)
          }
        }, (item: string) => item)
      } else {
        ListItem() {
          // 根据被点击事件的下标响应指定的信息
          Text(this.eventIndex === 0 ? $r('app.string.crash_event_message') :
            (this.eventIndex === 1 ? $r('app.string.freeze_event_message') :
              (this.faultSign ? $r('app.string.data_delay_toast') :
              $r('app.string.no_message'))))
        }
      }
    }
    .width('92%')
    .height(300)
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .borderRadius($r('app.string.ohos_id_corner_radius_default_m'))
    .padding($r('app.string.ohos_id_card_padding_start'))
  }
}
```
4. 以上代码中有引用懒加载数据类和持久化存储类，源码可参考[DataSource.ets](./src/main/ets/view/ApplicationException.ets)和
   [PreferencesManager.ets](./src/main/ets/view/ApplicationException.ets)。
```
// DataSource.ets
export class FaultDataSource extends BasicDataSource {
  // 懒加载数据
  private faultMessage: Array<string> = [];

  // TODO：知识点：获取懒加载数据源的数据长度
  totalCount(): number {
    return this.faultMessage.length;
  }

  // 获取指定数据项
  getData(index: number): string {
    return this.faultMessage[index];
  }

  // TODO：知识点：存储数据到懒加载数据源中
  pushData(data: string): void {
    this.faultMessage.push(data);
    // 在数组头部添加数据
    this.notifyDataAdd(this.faultMessage.length - 1);
    AppStorage.setOrCreate('faultDataSourceLength', this.totalCount());
  }

  // TODO：知识点：持久化存储异常信息集合
  persistenceStorage(): void {
    PreferencesManager.putFaultMessage(this.faultMessage);
  }
}

// PreferencesManager.ets
 /**
   * 存储数据异常信息
   * @param faultMessage 异常信息集合
   */
  public static putFaultMessage(faultMessage: Array<string>) {
    logger.info(`putMessage start`);
    try {
      // TODO：知识点：通过 dataPreferencesManager.put方法存储数据
      dataPreferencesManager.put('faultMessage', JSON.stringify(faultMessage), async (err: BusinessError) => {
        if (err) {
          logger.error("Failed to put value of 'faultMessage'. code =" + err.code + ", message =" + err.message);
          return;
        }
        logger.info('Succeeded in putting value of faultMessage.');
        dataPreferencesManager.flush();
      })
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      logger.error("Failed to put value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }

  /**
   * 获取数据异常信息
   * @param faultMessage 异常信息集合
   */
  public static getFaultMessage(faultDataSource:FaultDataSource) {
    logger.info(`getFaultMessage start`);
    try {
      // TODO：知识点：通过dataPreferencesManager.get方法获取异常信息数据
      let promise = dataPreferencesManager.get('faultMessage', []);
      promise.then(async (data: dataPreferences.ValueType) => {
        if (typeof data === 'string') {
          let faultData: Array<string> = JSON.parse(data);
          // 将异常数据添加到懒加载数据源中
          faultData.forEach((item: string) => {
            faultDataSource.pushData(item);
          })
          // 双向数据绑定懒加载数据源长度，更新数据源长度
          AppStorage.setOrCreate('faultDataSourceLength',faultDataSource.totalCount())
          logger.info('Succeeded in getting value of faultMessage.');
        }
      })
    } catch (err) {
      logger.error("Failed to get value of 'catch err'. code =" + err.code + ", message =" + err.message);
    }
  }
```

### 高性能知识点

本示例使用了[LazyForEach](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3)进行数据懒加载，将叠加获取到的应用异常信息进行渲染。

### 工程结构&模块类型

```
aplicationexception                             // har类型
|---model
|   |---DataSource.ets                          // 模型层-懒加载数据源
|   |---EventSubscription.ets                   // 数据模型层-订阅应用事件
|   |---MockData.ets                            // 数据模型层-模拟数据
|   |---PreferencesManager.ets                  // 数据模型层-持久化存储
|---view
|   |---PreferencesManager.ets                  // 视图层-应用异常页面
```
### 模块依赖

本实例依赖common模块来实现[日志](../../common/utils/src/main/ets/log/Logger.ets)的打印、[资源](../../common/utils/src/main/resources/base/element)的调用以及[公共组件FunctionDescription](../../common/utils/src/main/ets/component/FunctionDescription.ets)的引用。

### 参考资料

[应用事件打点HiAppEvent](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/js-apis-hiviewdfx-hiappevent-0000001478341401-V3)
[数据懒加载LazyForEach](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3)


