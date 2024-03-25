/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const TIME_ONE = 60000; // 1min = 60*1000ms
const TIME_TWO = 1000; // 1000ms
const TIME_THREE = 9; // 临界值

/**
 * 时间处理函数
 * @param time
 * @returns
 */
export function handleTime(time: number): string {
  const minInt: number = Math.floor(time / TIME_ONE);
  const minString: string = minInt > 0 ? (minInt > TIME_THREE ? minInt.toString() : `0${minInt}`) : '00';
  const secondsInt: number = Math.floor((time - minInt * TIME_ONE) / TIME_TWO);
  const secondsString: string = secondsInt > 0 ? (secondsInt > TIME_THREE ? secondsInt.toString() : `0${secondsInt}`) : '00';
  return `${minString}:${secondsString}`;
}