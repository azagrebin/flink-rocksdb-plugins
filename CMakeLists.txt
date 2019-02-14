cmake_minimum_required(VERSION 3.4)

project(rocksdb_plugins)
enable_language(CXX)
enable_language(C)

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

set(CMAKE_CXX_STANDARD 11)

set(ROCKSDB_PATH ../rocksdb2)
get_filename_component(ROCKSDB_ABS_PATH ${ROCKSDB_PATH} ABSOLUTE)

set(ROCKSDBLIBJNI_PATH ~/.m2/repository/org/rocksdb/rocksdbjni/5.17.2/tmp)
get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-osx.jnilib ABSOLUTE)
file(COPY ${ROCKSDBLIBJNI_ABS_PATH} DESTINATION ./java/target)

if(NOT WIN32)
    add_definitions(-DROCKSDB_PLATFORM_POSIX -DROCKSDB_LIB_IO_POSIX)
endif()

if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
    add_definitions(-DOS_MACOSX)
elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
    add_definitions(-DOS_LINUX)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
    add_definitions(-DWIN32 -DOS_WIN -D_MBCS -DWIN64 -DNOMINMAX)
endif()

include_directories("${ROCKSDB_ABS_PATH}")
include_directories("${ROCKSDB_ABS_PATH}/port")
include_directories("${ROCKSDB_ABS_PATH}/port/win")
include_directories("${ROCKSDB_ABS_PATH}/include")
include_directories("${ROCKSDB_ABS_PATH}/util")
include_directories("${ROCKSDB_ABS_PATH}/include/rocksdb")
include_directories("${ROCKSDB_ABS_PATH}/include/rocksdb/utilities")

option(WITH_TESTS "build with tests" ON)
if(WITH_TESTS)
    include_directories(SYSTEM ${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src)
    add_subdirectory(${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src/gtest ${CMAKE_CURRENT_BINARY_DIR}/gtest)

    add_executable(flink_compaction_filter_test src/flink_compaction_filter.cc src/flink_compaction_filter_test.cc)
    target_link_libraries(flink_compaction_filter_test gtest "${ROCKSDBLIBJNI_ABS_PATH}")
    set_target_properties(flink_compaction_filter_test PROPERTIES INSTALL_RPATH
            "/Users/azagrebin/projects/rocksdb_plugins")
endif()

include(FindJava)
include(UseJava)
include(FindJNI)

include_directories(${JNI_INCLUDE_DIRS})
include_directories(${ROCKSDB_ABS_PATH}/java)
include_directories(${ROCKSDB_ABS_PATH}/java/rocksjni)

add_library(rocksdb_plugins SHARED src/flink_compaction_filter.cc src/flink_compactionfilterjni.cc src/flink_compaction_filter.h)
if(NOT MSVC)
    set_property(TARGET rocksdb_plugins PROPERTY POSITION_INDEPENDENT_CODE ON)
endif()
target_link_libraries(rocksdb_plugins "${ROCKSDBLIBJNI_ABS_PATH}")