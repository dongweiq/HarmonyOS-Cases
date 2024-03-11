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
export class CardData {
  id: number;
  imageSrc: ResourceStr;
  title: Resource;
  content: Resource;
  authorName: Resource;
  avatorSrc: ResourceStr;
  cardArea: Area;

  constructor(id: number,
              imageSrc: ResourceStr,
              title: Resource,
              content: Resource,
              authorName: Resource,
              avatorSrc: ResourceStr) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.title = title;
    this.content = content;
    this.authorName = authorName;
    this.avatorSrc = avatorSrc;
    this.cardArea = {
      width: 0,
      height: 0,
      position: {
        x: 0,
        y: 0,
      },
      globalPosition: {
        x: 0,
        y: 0
      }
    }
  }
}