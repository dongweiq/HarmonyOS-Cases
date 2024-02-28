/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import worker, { ThreadWorkerGlobalScope, MessageEvents, ErrorEvent } from '@ohos.worker';
import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import zlib from '@ohos.zlib'; // 引入Zip解压模块
import { logger } from '@ohos/base';

const TAG: string = 'DecompressFileWorker';

// 绑定Worker对象
const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = (e: MessageEvents): void => {
  logger.info(TAG, `Worker onmessage：${JSON.stringify(e.data)}`);
  const pathDir: string = e.data.pathDir; // 沙箱目录
  const rawfileZipName: string = e.data.rawfileZipName; // 带.zip后缀的压缩文件名称
  // 沙箱目录和去掉文件名后缀的压缩文件名称拼接成解压输出目录
  const outFileDir: string = `${pathDir}/${rawfileZipName.split('.')[0]}`;
  // TODO：知识点：使用fs.access判断目录是否已经存在。
  fs.access(outFileDir).then((res: boolean) => {
    if (!res) {
      // TODO：知识点：使用fs.mkdirSync创建目录，用于存放解压后的文件。
      fs.mkdirSync(outFileDir);
      logger.info(TAG, 'mkdirSync succeed');
    }
    // TODO：知识点：使用zlib.decompressfile接口对沙箱目录中的压缩文件进行解压操作，解压至指定沙箱目录outFileDir。
    // 如果待解压的文件或文件夹在解压后的路径下已经存在，则会直接覆盖同名文件或同名文件夹中的同名文件。
    zlib.decompressFile(`${pathDir}/${rawfileZipName}`, outFileDir, (errData: BusinessError) => {
      if (errData !== null) {
        logger.error(TAG, `decompressFile failed. code is ${errData.code}, message is ${errData.message}`);
      } else {
        logger.info(TAG, `decompressFile succeed. outFileDir is ${outFileDir}`);
        // TODO：知识点：Worker线程向主线程发送信息。
        workerPort.postMessage(outFileDir);
      }
    })
  }).catch((err: BusinessError) => {
    logger.error(TAG, `access failed with error message: ${err.message}, error code: ${err.code}`);
  });
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = (e: MessageEvents): void => {
  logger.error(TAG, `Worker onmessageerror ${JSON.stringify(e.data)}`);
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = (e: ErrorEvent): void => {
  logger.error(TAG, `Worker: onerror = ${e.message}`);
};
