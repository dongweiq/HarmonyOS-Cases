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

import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constants/Constants'
import { util } from '@kit.ArkTS';
import { logger } from '@ohos/base';

let store: relationalStore.RdbStore | undefined = undefined;
const CONTEXT: Context = getContext(this);
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: Constants.DB_FILE_NAME,
  securityLevel: relationalStore.SecurityLevel.S1
};

/**
 * 对db操作进行封装，与业务隔离开
 */
export class DBUtils {
  /**
   * 初始化db
   */
  initDB() {
    if (store !== undefined) {
      return;
    }
    relationalStore.getRdbStore(CONTEXT, STORE_CONFIG, async (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      store = rdbStore;
      if (err) {
        logger.error(`init DB failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      await this.dropTable(Constants.STUDENT_TABLE, Constants.V1);
      await this.createTable(Constants.STUDENT_TABLE, Constants.V1_STUDENT_COLUMN_TYPE_MAP);
      await this.batchInsert(Constants.STUDENT_TABLE, Constants.students);
      this.commit();
    });
  }

  /**
   * 删除rdbStore
   */
  deleteRdbStore() {
    if (store === undefined) {
      return;
    }
    relationalStore.deleteRdbStore(CONTEXT, Constants.DB_FILE_NAME, (err) => {
      if (err) {
        logger.error('delete rdbStore failed');
      }
    })
  }

  /**
   * 创建表
   *
   * @param tableName 表名
   * @param columnTypeMap 字段名与其类型
   */
  async createTable(tableName: string, columnTypeMap: string[][]) {
    if (store === undefined) {
      return;
    }
    let fieldStatements: string = Constants.EMPTY_STRING;
    columnTypeMap.forEach(columnType => {
      fieldStatements += Constants.COMMA + columnType[0] + Constants.SPACE + columnType[1];
    })
    const createTableSql: string = util.format(Constants.CREATE_TABLE_SQL_TEMPLATE, tableName, fieldStatements);
    try {
      await store.executeSql(createTableSql);
    } catch (err) {
      logger.error(`createTable failed,code is ${err.code}, message is ${err.message}`);
    }
  }

  /**
   * 修改表名
   *
   * @param oldTableName 旧表名
   * @param newTableName 新表名
   */
  async updateTableName(oldTableName: string, newTableName: string): Promise<void> {
    if (store === undefined) {
      return;
    }
    const updateTableSql: string = util.format(Constants.UPDATE_TABLE_SQL_TEMPLATE, oldTableName, newTableName);
    try {
      await store.executeSql(updateTableSql);
    } catch (err) {
      logger.error(`updateTableName failed,code is ${err.code}, message is ${err.message}, the sql is ${updateTableSql}`);
    }
  }

  /**
   * 删除表
   *
   * @param tableName 表名
   */
  async dropTable(tableName: string, targetVersion: number) {
    if (store === undefined) {
      return;
    }
    const deleteTableSql: string = util.format(Constants.DROP_TABLE_SQL_TEMPLATE, tableName);
    try {
      await store.executeSql(deleteTableSql);
    } catch (err) {
      logger.error(`dropTable failed,code is ${err.code}, message is ${err.message}, the sql is ${deleteTableSql}`);
      return;
    }
    store.version = targetVersion;
  }

  /**
   * 批量插入数据
   * @param tableName 表名
   * @param data 数据
   * @returns 插入条数
   */
  async batchInsert(tableName: string, data: ValuesBucket[]) {
    if (store === undefined) {
      return;
    }
    await store.batchInsert(tableName, data);
  }

  rollback() {
    if (store !== undefined) {
      store.rollBack();
    }
  }

  commit() {
    if (store !== undefined) {
      store.commit();
    }
  }

  beginTransaction() {
    if (store !== undefined) {
      store.beginTransaction();
    }
  }

  getStoreVersion(): number {
    if (store !== undefined) {
      return store.version;
    }
    return -1;
  }

  /**
   * 通用查询
   * @param tableName 表名
   * @param limit     最大查询数量
   * @param lastId    上一次查询id
   * @param callback  业务逻辑
   */
  async queryData(tableName: string, limit: number, lastId: number, callback: (result: relationalStore.ResultSet) => Promise<void>) {
    if (store === undefined) {
      return;
    }
    const querySql: string = util.format(Constants.QUERY_TABLE_SQL_TEMPLATE, tableName, lastId, limit);
    try {
      const resultSet = await store.querySql(querySql)
      await callback(resultSet);
      resultSet.close();
    } catch (err) {
      logger.error(`query failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  /**
   * 备份数据库
   * @param callback 版本升级方法
   * @param version 版本
   */
  async backup(version: number) {
    if (store === undefined) {
      return;
    }
    await store.backup(version + Constants.DB_FILE_NAME_SUFFIX);
  }

  /**
   * 恢复数据库
   * @param callback 版本升级方法
   * @param version 版本
   */
  async restore(version: number) {
    if (store === undefined) {
      return;
    }
    await store.restore(version + Constants.DB_FILE_NAME_SUFFIX);
  }
}

const dbUtils: DBUtils = new DBUtils();

export default dbUtils as DBUtils;