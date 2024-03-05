import Constants from './Constants';
import napi from 'libpreloadso.so';
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import { logger } from '@ohos/base';

const TAG = 'TaskPool';

/**
 * 开启taskpool子线程预加载so
 * @param
 * @returns string[] 加载完成的so库
 */
@Concurrent
function preloadSO(): string[] {
  return napi.preload(Constants.LIBRARY_PATH_ARRAY);
}

/**
 * 开启taskpool子线程
 * @param
 * @returns Promise<string[]> 异步返回加载完成的so库
 */
export function preloadSOByTaskPool(): void {
  // TODO: 知识点：使用new taskpool.Task()创建任务项，传入任务执行函数和所需参数
  const task: taskpool.Task = new taskpool.Task(preloadSO);
  try {
    // TODO：知识点：使用taskpool.execute将待执行的函数放入TaskPool内部任务队列等待执行
    taskpool.execute(task, taskpool.Priority.HIGH).then((res: Object) => {
      // so库预加载完成的处理
      logger.info(TAG, '%{public}s', 'PreloadSOByTaskPool：' + JSON.stringify(res));
    })
  } catch (err) {
    logger.error(TAG, "PreloadSOByTaskPool: execute failed, " + (err as BusinessError).toString());
  }
}

