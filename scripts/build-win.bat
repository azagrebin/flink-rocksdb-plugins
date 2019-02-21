:: choco install git.install jdk8 maven visualstudio2017community intellijidea-community vscode

set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe
set CWD=%CD%

set BUILD_DIR=%1
if "%BUILD_DIR%"=="" (set BUILD_DIR=build-win)
set ROCKSDB_VERSION=%2
if "%ROCKSDB_VERSION%"=="" (set ROCKSDB_VERSION=5.17.2)
set ROCKSDB_BIN=%3
if "%ROCKSDB_BIN%"=="" (set ROCKSDB_BIN=rocksdbjni-bin)
set ROCKSDB_SOURCE_PATH=%4
if "%ROCKSDB_SOURCE_PATH%"=="" (set ROCKSDB_SOURCE_PATH=..\rocksdb)

:: copy some rocksdb sources to not depend on rocksdb binaries
copy %ROCKSDB_SOURCE_PATH%\util\slice.cc src\.

if exist %BUILD_DIR% rd /s /q %BUILD_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake -G "Visual Studio 15 Win64" .. -DROCKSDB_PATH=%ROCKSDB_SOURCE_PATH%

"%MSBUILD%" rocksdb_plugins.sln /p:Configuration=Release /m

cd %CWD%

set LIB_NAME=rocksdb_plugins.dll
set JAVA_OUT_PATH=java\src\main\resources
if not exist %JAVA_OUT_PATH% mkdir %JAVA_OUT_PATH%
copy %BUILD_DIR%\Release\%LIB_NAME% %JAVA_OUT_PATH%\lib%LIB_NAME%

cd java
mvn clean install
cd %CWD%