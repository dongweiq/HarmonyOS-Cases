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

/**
 * 笔记信息类型
 */
export class MemoInfo {
  memoId: string;
  title: string;
  time: string;
  imageSrc: string;
  content: string;


  constructor(memoId: string, title: string, time: string, imageSrc: string, content: string) {
    this.memoId = memoId;
    this.title = title;
    this.time = time;
    this.imageSrc = imageSrc;
    this.content = content;
  }
}
