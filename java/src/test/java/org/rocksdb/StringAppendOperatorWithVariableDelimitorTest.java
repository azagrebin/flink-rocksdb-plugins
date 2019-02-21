/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.rocksdb;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import static org.assertj.core.api.Assertions.assertThat;

public class StringAppendOperatorWithVariableDelimitorTest {
    @Rule
    public TemporaryFolder dbFolder = new TemporaryFolder();

    @Test
    public void stringDelimiter() throws RocksDBException {
        stringDelimiter("DELIM");
        stringDelimiter("");
    }

    private void stringDelimiter(String delim) throws RocksDBException {
        try (final MergeOperator stringAppendOperator = new StringAppendOperatorWithVariableDelimitor(delim.getBytes());
             final Options opt = new Options()
                     .setCreateIfMissing(true)
                     .setMergeOperator(stringAppendOperator);
             final RocksDB db = RocksDB.open(opt, dbFolder.getRoot().getAbsolutePath())) {
            // Writing aa under key
            db.put("key".getBytes(), "aa".getBytes());

            // Writing bb under key
            db.merge("key".getBytes(), "bb".getBytes());

            // Writing empty under key
            db.merge("key".getBytes(), "".getBytes());

            final byte[] value = db.get("key".getBytes());
            final String strValue = new String(value);

            assertThat(strValue).isEqualTo("aa" + delim + "bb" + delim);
        }
    }
}
