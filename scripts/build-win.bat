:: install git, java 8, maven, visual studio community 15 (2017)

:: vcpkg install rocksdb:5.17.2:x64-windows

set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe
set JARTOOL=C:\Program Files\Java\jdk1.8.0_201\bin\jar.exe
set CWD=%CD%

set BUILD_DIR=%1
if "%BUILD_DIR%"=="" (set BUILD_DIR=build-win)
set ROCKSDB_VERSION=%2
if "%ROCKSDB_VERSION%"=="" (set ROCKSDB_VERSION=5.17.2)
set ROCKSDB_BIN=%3
if "%ROCKSDB_BIN%"=="" (set ROCKSDB_BIN=rocksdbjni-bin)
set ROCKSDB_PATH=%4
if "%ROCKSDB_PATH%"=="" (set ROCKSDB_PATH=..\rocksdb)

set JAR=rocksdbjni-%ROCKSDB_VERSION%.jar
set MVNJAR=%HOMEPATH%\.m2\org\rocksdb\rocksdbjni\%ROCKSDB_VERSION%\%JAR%
set OUTJAR=%ROCKSDB_BIN%\%JAR%

if exist %ROCKSDB_BIN% rd /s /q %ROCKSDB_BIN%
mkdir %ROCKSDB_BIN%

if exist %MVNJAR% (
    copy %MVNJAR% %ROCKSDB_BIN%\.
) else (
    curl -o %OUTJAR% "http://central.maven.org/maven2/org/rocksdb/rocksdbjni/%ROCKSDB_VERSION%/%JAR%"
)

cd %ROCKSDB_BIN%
"%JARTOOL%" -xvf %JAR%
cd %CWD%

:: call scripts\generate-lib.bat
:: copy ..\rocksdb\build\Release\rocksdb.lib %ROCKSDB_BIN%\librocksdbjni-win64.lib

if exist %BUILD_DIR% rd /s /q %BUILD_DIR%
:: if exist librocksdbjni-win64.dll del librocksdbjni-win64.dll
mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake -G "Visual Studio 15 Win64" .. -DROCKSDBLIBJNI_PATH=%ROCKSDB_BIN% -DROCKSDB_PATH=%ROCKSDB_PATH% -DCMAKE_TOOLCHAIN_FILE="D:\vcpkg\scripts\buildsystems\vcpkg.cmake"

"%MSBUILD%" rocksdb_plugins.sln

cd %CWD%