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

import dbUtils from '../utils/DBUtils';
import { Constants } from '../constants/Constants';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import CommonUtils from '../utils/CommonUtils';

/**
 * 数据库版本升级基础业务层
 */
export abstract class BaseDataService {
  async onUpgrade(targetVersion: number): Promise<void> {
    // 开启事务
    dbUtils.beginTransaction();
    // 获取当前数据库版本
    const oldVersion: number = dbUtils.getStoreVersion();
    // 将旧表改为临时表
    await dbUtils.updateTableName(Constants.STUDENT_TABLE, Constants.STUDENT_TABLE + oldVersion);
    // 创建新表
    const newTableColumnTypeMap: string[][] = CommonUtils.getTableColumnTypeMapByVersion(targetVersion);
    await dbUtils.createTable(Constants.STUDENT_TABLE, newTableColumnTypeMap);
    dbUtils.commit();
    // 自定义迁移逻辑
    const  LAST_ID: number = -1;
    const  FLAG: boolean = false;
    await this.migrate(LAST_ID, oldVersion, targetVersion, FLAG);
    // 删除旧表
    await dbUtils.dropTable(Constants.STUDENT_TABLE + oldVersion, targetVersion);
  }

  /**
   * 递归方式批次查询旧表数据
   * @param lastId 上一次查询的最后一个id
   * @param targetVersion 目标版本
   */
  private async migrate(lastId: number, oldVersion: number, targetVersion: number, flag: boolean): Promise<void> {
    if (flag) {
      return;
    }
    let newDataArray: ValuesBucket[] = new Array();
    await dbUtils.queryData(Constants.STUDENT_TABLE + oldVersion, Constants.MAX_BATCH_NUM, lastId, async (resultSet) => {
      if (resultSet.rowCount === 0) {
        flag = true;
        return;
      }
      // 对查询的旧表数据依次进行转换
      while (resultSet.goToNextRow()) {
        const  newData: ValuesBucket = this.transform(resultSet, targetVersion);
        newDataArray.push(newData);
        if (resultSet.isAtLastRow) {
          lastId = newData[Constants.ID_STR] as number;
          break;
        }
      }
      if (newDataArray.length === 0) {
        return;
      }
      // 将转换后的数据存入新表
      await dbUtils.batchInsert(Constants.STUDENT_TABLE, newDataArray);
      await this.migrate(lastId, oldVersion, targetVersion, flag);
    })
  }

  /**
   * TODO： 知识点： 新老版本字段转换逻辑（版本升级只需要实现这个方法即可）
   * @param resultSet 查询结果集
   * @param targetVersion 目标版本
   * @returns 目标版本格式数据
   */
  abstract transform(resultSet: relationalStore.ResultSet, targetVersion: number): ValuesBucket;
}

/**
 * V1版本升级数据处理业务层
 */
export class V1DataService extends BaseDataService {
  /**
   * V1新老版本字段转换逻辑
   * @param resultSet 查询结果集
   * @param targetVersion 目标版本
   * @returns 目标版本格式数据
   */
  transform(resultSet: relationalStore.ResultSet, targetVersion: number): ValuesBucket {
    switch (targetVersion) {
      case Constants.V2:
        return this.transformV1ToV2(resultSet);
      case Constants.V3:
        return this.transformV1ToV3(resultSet);
      default: {
        throw new Error('The database version to which you need to upgrade is incorrect');
      }
    }
  }

  private transformV1ToV3(resultSet: relationalStore.ResultSet): ValuesBucket {
    // 新增了个字段teacherFirstName，删除了个字段className
    const id: number = resultSet.getLong(resultSet.getColumnIndex(Constants.ID_STR));
    const name: string = resultSet.getString(resultSet.getColumnIndex(Constants.V1_STUDENT_COLUMN_TYPE_MAP[0][0]));
    const teacherFirstName: string = Constants.DEFAULT_TEACHER_FIRST_NAME;
    const newData: ValuesBucket = { 'id': id, 'name': name, 'teacherFirstName': teacherFirstName };
    return newData;
  }

  private transformV1ToV2(resultSet: relationalStore.ResultSet): ValuesBucket {
    // 新增了个字段teacherName，删除了个字段className
    const id: number = resultSet.getLong(resultSet.getColumnIndex(Constants.ID_STR));
    const name: string = resultSet.getString(resultSet.getColumnIndex(Constants.V1_STUDENT_COLUMN_TYPE_MAP[0][0]));
    const teacherName: string = Constants.DEFAULT_TEACHER_NAME;
    const newData: ValuesBucket = { 'id': id, 'name': name, 'teacherName': teacherName };
    return newData;
  }
}

/**
 * V2版本升级数据处理业务层
 */
export class V2DataService extends BaseDataService {
  /**
   * V2新老版本字段转换逻辑
   * @param resultSet 查询结果集
   * @param targetVersion 目标版本
   * @returns 目标版本格式数据
   */
  transform(resultSet: relationalStore.ResultSet, targetVersion: number): ValuesBucket {
    if (targetVersion === Constants.V3) {
      // 将teacherName字段改为teacherFirstName字段
      return this.transformV2ToV3(resultSet);
    } else {
      throw new Error('The database version to which you need to upgrade is incorrect');
    }
  }

  private transformV2ToV3(resultSet: relationalStore.ResultSet): ValuesBucket {
    const id: number = resultSet.getLong(resultSet.getColumnIndex(Constants.ID_STR));
    const name: string = resultSet.getString(resultSet.getColumnIndex(Constants.V2_STUDENT_COLUMN_TYPE_MAP[0][0]));
    const teacherName: string = resultSet.getString(resultSet.getColumnIndex(Constants.V2_STUDENT_COLUMN_TYPE_MAP[1][0]));
    const teacherFirstName: string = teacherName.split(Constants.EMPTY_STRING)[0];
    const newData: ValuesBucket = { 'id': id, 'name': name, 'teacherFirstName': teacherFirstName };
    return newData;
  }
}