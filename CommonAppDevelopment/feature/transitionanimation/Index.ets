import { RouterInfo } from '@ohos/dynamicsrouter/Index';

export { TransitionAnimationPage } from './src/main/ets/components/pages/TransitionAnimationPage';

// 动态import时需要调用的接口，接口名请使用harInit，用于动态加载页面
export function harInit(pageName: string) {
  switch (pageName) {
    case RouterInfo.PAGE_LOADING.pageName:
      import('./src/main/ets/components//pages//TransitionAnimationPage');
      break;
  }
}
