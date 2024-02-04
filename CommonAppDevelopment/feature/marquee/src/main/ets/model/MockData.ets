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

import { TripDataType } from './DataType';

// 模拟行程数据
export const TRIP_DATA: Array<TripDataType> = [
  {
    id: 0,
    trainNumber: "K101",
    wholeCourse: $r('app.string.whole_course_data_1'),
    startingTime: "8:46",
    endingTime: "9:36",
    timeDifference: $r('app.string.time_difference_data_1'),
    origin: $r('app.string.origin_data'),
    destination: $r('app.string.destination_data_1'),
    ticketEntrance: $r('app.string.ticket_entrance_data_1'),
    vehicleModel: $r('app.string.vehicle_model_data_1')
  },
  {
    id: 1,
    trainNumber: "G101",
    wholeCourse: $r('app.string.whole_course_data_2'),
    startingTime: "9:26",
    endingTime: "13:36",
    timeDifference: $r('app.string.time_difference_data_2'),
    origin: $r('app.string.origin_data'),
    destination:  $r('app.string.destination_data_2'),
    ticketEntrance: $r('app.string.ticket_entrance_data_2'),
    vehicleModel: $r('app.string.vehicle_model_data_2')
  }
]