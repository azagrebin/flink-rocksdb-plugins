cmake_minimum_required(VERSION 2.8)

project(rocksdb_plugins)
enable_language(CXX)
enable_language(C)

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

if(NOT ROCKSDBLIBJNI_PATH)
    set(ROCKSDB_PATH ${CMAKE_SOURCE_DIR}/../rocksdb)
endif()
get_filename_component(ROCKSDB_ABS_PATH ${ROCKSDB_PATH} ABSOLUTE)

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

set(SOURCES
        src/flink_compaction_filter.cc
        src/slice.cc
        src/log.cc)

set(JNI_SOURCES
        src/flink_compactionfilterjni.cc)

set(TEST_SOURCES
        src/flink_compaction_filter_test.cc)

option(WITH_TESTS "build with tests" ON)
if(WITH_TESTS)
    include_directories(SYSTEM ${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src)
    add_subdirectory(${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src/gtest ${CMAKE_CURRENT_BINARY_DIR}/gtest)

    add_executable(flink_compaction_filter_test ${SOURCES} ${TEST_SOURCES})
    target_link_libraries(flink_compaction_filter_test gtest)
endif()

include(FindJava)
include(UseJava)
include(FindJNI)

include_directories(${JNI_INCLUDE_DIRS})
include_directories(${ROCKSDB_ABS_PATH}/java)
include_directories(${ROCKSDB_ABS_PATH}/java/rocksjni)

add_library(rocksdb_plugins SHARED ${SOURCES} ${JNI_SOURCES})
if(NOT MSVC)
    set_property(TARGET rocksdb_plugins PROPERTY POSITION_INDEPENDENT_CODE ON)
endif()