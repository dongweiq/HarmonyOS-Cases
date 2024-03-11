import { RouterInfo } from '@ohos/dynamicsrouter/Index';

export {
  registryDocumentViewPickerFn,
  generateAbilityID,
  addUIContext,
  setTopAbilityID,
  removeUIContext
} from './src/main/ets/wrapper/wrapper';

export { MockNativeCallPickerView } from './src/main/ets/view/MockNativeCallPickerView';

// 动态import时需要调用的接口，接口名请使用harInit，用于动态加载页面
export function harInit(pageName: string) {
  switch (pageName) {
    case RouterInfo.ETS_WRAPPER.pageName:
      import('./src/main/ets/view/MockNativeCallPickerView');
      break;
  }
}