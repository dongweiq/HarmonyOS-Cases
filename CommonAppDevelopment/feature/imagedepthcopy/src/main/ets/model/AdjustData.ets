/*
 * Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export enum CropTasks {
  ORIGIN,
  ONE_ONE,
  THREE_FOUR,
  NINE_SIXTH,
  NONE = 99
}

export class TaskData {
  task?: number
  image?: Resource
  text?: Resource

  constructor(task?: number, image?: Resource, text?: Resource) {
    this.task = task;
    this.image = image;
    this.text = text;
  }
}

/**
 * 裁剪图片按钮资源
 */
export const cropTaskDatas: TaskData[] = [
  new TaskData(CropTasks.ORIGIN, $r('app.media.ic_origin'), $r('app.string.origin_photo')),
  new TaskData(CropTasks.THREE_FOUR, $r('app.media.three_four_gray'), $r('app.string.proportion_three_four')),
  new TaskData(CropTasks.NINE_SIXTH, $r('app.media.nine_sixth_gray'), $r('app.string.proportion_nine_sixth')),
  new TaskData(CropTasks.ONE_ONE, $r('app.media.one_one_gray'), $r('app.string.proportion_one_one'))
];