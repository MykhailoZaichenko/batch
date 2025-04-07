@echo off
set SourceDir="Un_hiden_folder"
set TargetDir="Hiden_folder"

rem ����������, �� ���� ������� �����
if not exist "%SourceDir%" (
    echo Error: The source folder does not exist.
    pause
    exit /b
)

rem ��������� ������� �����, ���� �� ����
if not exist "%TargetDir%" (
    mkdir "%TargetDir%"
)

rem ����������, �� ���� ������� �����
if not exist "%TargetDir%" (
    echo The destination folder does not exist, creating...
    mkdir "%TargetDir%"
)

rem ���������� ��� �����
move "%SourceDir%\*" "%TargetDir%"

rem ���� ����������� ��� ����
echo All files moved to "%TargetDir%"
pause
