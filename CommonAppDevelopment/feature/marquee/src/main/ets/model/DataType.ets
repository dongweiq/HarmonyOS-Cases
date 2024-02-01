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
 * 行程信息类型
 *
 * @param id
 * @param trainNumber 列车号
 * @param wholeCourse 全程
 * @param startingTime 起始时间
 * @param endingTime 终止时间
 * @param timeDifference 距出发时间
 * @param origin 起始位置
 * @param destination 目的地
 * @param ticketEntrance 检票口
 * @param vehicleModel 车型
 */
export interface TripDataType {
  id: number;
  trainNumber: string;
  wholeCourse: ResourceStr;
  startingTime: string;
  endingTime: string;
  timeDifference: ResourceStr;
  origin: ResourceStr;
  destination: ResourceStr;
  ticketEntrance: ResourceStr;
  vehicleModel: ResourceStr;
}