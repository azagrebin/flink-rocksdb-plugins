// Copyright (c) 2011-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under both the GPLv2 (found in the
//  COPYING file in the root directory) and Apache 2.0 License
//  (found in the LICENSE.Apache file in the root directory).

#include "stringappend_delim.h"

#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory>
#include <string>

#include "rocksjni/portal.h"
#include "stringappend_delim.h"
#include "org_rocksdb_StringAppendOperatorWithVariableDelimitor.h"

/*
 * Class:     org_rocksdb_StringAppendOperatorWithVariableDelimitor
 * Method:    newSharedStringAppendDelimOperator
 * Signature: ([B)J
 */
jlong Java_org_rocksdb_StringAppendOperatorWithVariableDelimitor_newSharedStringAppendDelimOperator(
        JNIEnv* env, jclass /*jclazz*/, jbyteArray jdelim) {
    jboolean has_exception = JNI_FALSE;
    std::string delim = rocksdb::JniUtil::byteString<std::string>(
            env, jdelim,
            [](const char* str, const size_t len) { return std::string(str, len); },
            &has_exception);
    if (has_exception == JNI_TRUE) {
        // exception occurred
        return 0;
    }

    auto* sptr_string_append_test_op = new std::shared_ptr<rocksdb::MergeOperator>(
            std::make_shared<rocksdb::StringAppendDelimOperator>(delim));
    return reinterpret_cast<jlong>(sptr_string_append_test_op);
}

/*
 * Class:     org_rocksdb_StringAppendOperatorWithVariableDelimitor
 * Method:    disposeInternal
 * Signature: (J)V
 */
void Java_org_rocksdb_StringAppendOperatorWithVariableDelimitor_disposeInternal(JNIEnv* /*env*/,
                                                                                jobject /*jobj*/,
                                                                                jlong jhandle) {
    auto* sptr_string_append_test_op =
            reinterpret_cast<std::shared_ptr<rocksdb::MergeOperator>*>(jhandle);
    delete sptr_string_append_test_op;  // delete std::shared_ptr
}