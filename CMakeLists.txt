cmake_minimum_required(VERSION 2.8)

if(NOT LIBNAME)
    set(LIBNAME frocksdbplugins)
endif()

if(NOT ROCKSDB_SOURCE_PATH)
    set(ROCKSDB_SOURCE_PATH ${CMAKE_SOURCE_DIR}/rocksdb)
endif()

if (NOT TESTS)
    set(TESTS flink_compaction_filter_test)
endif()

project(${LIBNAME})
enable_language(CXX)
enable_language(C)

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

get_filename_component(ROCKSDB_ABS_PATH ${ROCKSDB_SOURCE_PATH} ABSOLUTE)

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
include_directories("${ROCKSDB_ABS_PATH}/java")
include_directories("${ROCKSDB_ABS_PATH}/java/rocksjni")

set(SOURCES
        src/flink_compaction_filter.cc
        src/stringappend_delim.cc
        src/log.cc
        src/slice.cc
        src/merge_operator.cc)

set(JNI_SOURCES
        src/flink_compactionfilterjni.cc
        src/stringappend_delim_jni.cc)

include(FindJava)
include(UseJava)
include(FindJNI)
include_directories("${JNI_INCLUDE_DIRS}")

add_library(${LIBNAME} SHARED ${SOURCES} ${JNI_SOURCES})

# tests

option(WITH_TESTS "build with tests" ON)
if(WITH_TESTS)
    enable_testing()

    foreach(TEST ${TESTS})
        list(APPEND TEST_SOURCES "src/${TEST}.cc")
    endforeach()

    include_directories(SYSTEM ${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src)
    add_subdirectory(${ROCKSDB_ABS_PATH}/third-party/gtest-1.7.0/fused-src/gtest ${CMAKE_CURRENT_BINARY_DIR}/gtest)

    foreach(TEST ${TESTS})
        add_executable(${TEST} ${SOURCES} ${TEST_SOURCES})
        target_link_libraries(${TEST} gtest)
        if(NOT WIN32)
            target_link_libraries(${TEST} pthread)
        endif()
        add_test(${TEST} ${TEST})
        add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} DEPENDS ${TEST})
    endforeach()
endif()