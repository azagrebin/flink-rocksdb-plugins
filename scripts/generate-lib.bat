set VCTOOLPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.16.27023\bin\Hostx86\x86
set DUMPBIN=%VCTOOLPATH%\dumpbin.exe
set LIBTOOL=%VCTOOLPATH%\lib.exe

set ROCKSDB_BIN=%1
if "%ROCKSDB_BIN%"=="" (set ROCKSDB_BIN=rocksdbjni-bin)

set DLL_NAME=librocksdbjni-win64
set DEF=%ROCKSDB_BIN%\%DLL_NAME%.def
set EXPORTS=%ROCKSDB_BIN%\exports.txt

"%DUMPBIN%" /exports "%ROCKSDB_BIN%\%DLL_NAME%.dll" > "%EXPORTS%"

echo LIBRARY %DLL_NAME% > "%DEF%"
echo EXPORTS >> "%DEF%"
for /f "skip=19 tokens=4" %%A in (%EXPORTS%) do echo %%A >> "%DEF%"

"%LIBTOOL%" /def:"%DEF%" /out:"%ROCKSDB_BIN%\%DLL_NAME%.lib" /machine:x64