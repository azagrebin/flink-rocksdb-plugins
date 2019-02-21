// Copyright (c) 2011-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under both the GPLv2 (found in the
//  COPYING file in the root directory) and Apache 2.0 License
//  (found in the LICENSE.Apache file in the root directory).

#pragma once
#include <deque>
#include <string>
#include <utility>
#include "rocksdb/merge_operator.h"
#include "rocksdb/slice.h"

namespace rocksdb {

class StringAppendDelimOperator : public MergeOperator {
 public:
  // Constructor with string delimiter
  explicit StringAppendDelimOperator(std::string delim_str) : delim_(std::move(delim_str)) {};

  // Constructor with char delimiter
  explicit StringAppendDelimOperator(char delim_char) : delim_(std::string(1, delim_char)) {};

  bool FullMergeV2(const MergeOperationInput& merge_in,
                   MergeOperationOutput* merge_out) const override;

  bool PartialMergeMulti(const Slice& key,
                         const std::deque<Slice>& operand_list,
                         std::string* new_value, Logger* logger) const override;

  const char* Name() const override;

 private:
  // A version of PartialMerge that actually performs "partial merging".
  // Use this to simulate the exact behaviour of the StringAppendOperator.
  bool _AssocPartialMergeMulti(const Slice& key,
                               const std::deque<Slice>& operand_list,
                               std::string* new_value, Logger* logger) const;

  std::string delim_;         // The delimiter is inserted between elements

};

} // namespace rocksdb
