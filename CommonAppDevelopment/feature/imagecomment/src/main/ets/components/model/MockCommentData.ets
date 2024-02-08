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

import { Comment, CommentData } from './CommentModel';

// 模拟评论数据
export function mockData(): CommentData {
  let commentList: CommentData = new CommentData();
  commentList.pushData(new Comment('Cloud', "这里的风景很好", $r('app.media.app_logo1'), [$r('app.media.landscape5')], '02-07 13:25'));
  commentList.pushData(new Comment('晨风', "下次还会再来！", $r('app.media.app_logo2'), [$r('app.media.launch_advert'),$r('app.media.arc_of_light')], '01-03 14:55'));
  commentList.pushData(new Comment('来自星星', "风景这边独好", $r('app.media.app_logo3'), [$r('app.media.landscape1'),$r('app.media.landscape2'),$r('app.media.landscape3'),$r('app.media.landscape4')], '01-31 07:23'));
  return commentList;
}