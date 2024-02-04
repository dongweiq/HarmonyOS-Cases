export { ImageViewerView } from './src/main/ets/view/ImageViewerView';

// 动态import时需要调用的接口，接口名请使用harInit，用于动态加载页面
export function harInit() {
  import('./src/main/ets/view/ImageViewerView');
}
