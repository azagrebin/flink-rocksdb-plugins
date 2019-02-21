set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe
set CWD=%CD%

set BUILD_DIR=%1
if "%BUILD_DIR%"=="" (set BUILD_DIR=build-win)
set ROCKSDB_SOURCE_PATH=%2
if "%ROCKSDB_SOURCE_PATH%"=="" (set ROCKSDB_SOURCE_PATH=rocksdb)
set LIBNAME=%3
if "%LIBNAME%"=="" (set LIBNAME=frocksdbplugins)

set LIBFULLNAME=%LIBNAME%jni-win64

cd java
call mvn clean compile &:: generate jni headers
cd %CWD%

:: copy some rocksdb sources to not depend on rocksdb binaries
copy %ROCKSDB_SOURCE_PATH%\util\slice.cc src\.
copy %ROCKSDB_SOURCE_PATH%\db\merge_operator.cc src\.

if exist %BUILD_DIR% rd /s /q %BUILD_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake -G "Visual Studio 15 Win64" .. -DROCKSDB_SOURCE_PATH=%ROCKSDB_SOURCE_PATH% -DLIBNAME=%LIBFULLNAME%

"%MSBUILD%" %LIBFULLNAME%.sln /p:Configuration=Release /m

ctest

cd %CWD%

set LIB=%LIBFULLNAME%.dll
set JAVA_OUT_PATH=java\src\main\resources
set JAVA_OUT=%JAVA_OUT_PATH%\lib%LIB%
if not exist %JAVA_OUT_PATH% mkdir %JAVA_OUT_PATH%
copy %BUILD_DIR%\Release\%LIB% %JAVA_OUT%

cd java
call mvn clean install
cd %CWD%

echo Result is in:
echo %JAVA_OUT%