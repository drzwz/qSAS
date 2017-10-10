@echo off
rem 1.自行启动SAS，并运行qsas.sas

rem 2.启动测试行情，发送给SAS
set qhome=%~dp0q
cd %~dp0
rem                             qsas.q 后面的数字表示推送频率，单位为毫秒，如2000表示2秒推送1次。
start "qsas"   %~dp0q\w32\q.exe qsas.q   1000   -p 5565 -U %~dp0q/qusers
