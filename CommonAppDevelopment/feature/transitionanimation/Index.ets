export { TransitionAnimationPage } from './src/main/ets/components/pages/TransitionAnimationPage'

// 动态import时需要调用的接口，接口名请使用harInit，用于动态加载页面
export function harInit(path: string) {
  import(path);
}
