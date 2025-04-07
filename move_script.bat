@echo off
set SourceDir="Un_hiden_folder"
set TargetDir="Hiden_folder"

rem Перевіряємо, чи існує вихідна папка
if not exist "%SourceDir%" (
    echo Error: The source folder does not exist.
    pause
    exit /b
)

rem Створення цільової папки, якщо її немає
if not exist "%TargetDir%" (
    mkdir "%TargetDir%"
)

rem Перевіряємо, чи існує цільова папка
if not exist "%TargetDir%" (
    echo The destination folder does not exist, creating...
    mkdir "%TargetDir%"
)

rem Переміщення всіх файлів
move "%SourceDir%\*" "%TargetDir%"

rem Вивід повідомлення про успіх
echo All files moved to "%TargetDir%"
pause
