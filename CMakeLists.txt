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

if(NOT ROCKSDBLIBJNI_PATH)
    set(ROCKSDBLIBJNI_PATH ${CMAKE_SOURCE_DIR}/rocksdbjni-bin)
endif()

if (APPLE)
    find_library(rocksdbjni NAMES rocksdbjni-osx PATHS "${ROCKSDBLIBJNI_PATH}")
    get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-osx.jnilib ABSOLUTE)
elseif (WIN32)
    #SET(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
    #find_library(rocksdbjni NAMES "librocksdbjni-win64" PATHS "${ROCKSDBLIBJNI_PATH}" NO_DEFAULT_PATH) 
    find_package(RocksDB CONFIG)
    set(rocksdbjni RocksDB::rocksdb)
    get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-win64.dll ABSOLUTE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64le")
    find_library(rocksdbjni NAMES rocksdbjni-linux-ppc64le PATHS "${ROCKSDBLIBJNI_PATH}")
    get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-linux-ppc64le.so ABSOLUTE)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    find_library(rocksdbjni NAMES rocksdbjni-linux64 PATHS "${ROCKSDBLIBJNI_PATH}")
    get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-linux64.so ABSOLUTE)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86")
    find_library(rocksdbjni NAMES rocksdbjni-linux32PATHS "${ROCKSDBLIBJNI_PATH}")
    get_filename_component(ROCKSDBLIBJNI_ABS_PATH ${ROCKSDBLIBJNI_PATH}/librocksdbjni-linux32.so ABSOLUTE)
else()
    message(FATAL_ERROR "Unsupported CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

file(COPY ${ROCKSDBLIBJNI_ABS_PATH} DESTINATION .)

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
    target_link_libraries(flink_compaction_filter_test gtest ${rocksdbjni})
    if (APPLE)
        add_custom_command(TARGET flink_compaction_filter_test
                POST_BUILD COMMAND
                ${CMAKE_INSTALL_NAME_TOOL} -change "./java/target/librocksdbjni-osx.jnilib" "@loader_path/librocksdbjni-osx.jnilib" $<TARGET_FILE:flink_compaction_filter_test>)
    endif()
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
target_link_libraries(rocksdb_plugins ${rocksdbjni})
if (APPLE)
    add_custom_command(TARGET rocksdb_plugins
            POST_BUILD COMMAND
            ${CMAKE_INSTALL_NAME_TOOL} -change "./java/target/librocksdbjni-osx.jnilib" "@loader_path/librocksdbjni-osx.jnilib" $<TARGET_FILE:rocksdb_plugins>)
endif()