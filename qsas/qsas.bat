@echo off
rem 1.��������SAS��������qsas.sas

rem 2.�����������飬���͸�SAS
set qhome=%~dp0q
cd %~dp0
rem                             qsas.q ��������ֱ�ʾ����Ƶ�ʣ���λΪ���룬��2000��ʾ2������1�Ρ�
start "qsas"   %~dp0q\w32\q.exe qsas.q   1000   -p 5565 -U %~dp0q/qusers
