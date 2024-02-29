import { RouterInfo } from '@ohos/dynamicsrouter/Index';
export { BigFileCopyView } from './src/main/ets/view/BigFileCopyView';

// 动态import时需要调用的接口，接口名请使用harInit，用于动态加载页面
export function harInit(pageName: string) {
  switch (pageName) {
    case RouterInfo.BIG_FILE_COPY.pageName:
      import('./src/main/ets/view/BigFileCopyView');
      break;
  }
}