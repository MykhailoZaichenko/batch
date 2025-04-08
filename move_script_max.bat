@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem If the script is run without parameters, show usage message
if "%~1"=="" (
    echo Program for moving files. For help in usage print move_utility.bat -h or move_utility.bat --help
    cmd /K
)

rem Help handling
if "%~1"=="-h" (
    echo Usage: move_utility.bat Source_Folder Destination_Folder fileName.fileExtension
    echo Moves all files from the source folder to the destination, handling file attributes.
    echo Termination codes:
    echo "0 -> Successful move"
    echo "1 -> Help displayed (-h or --help)"
    echo "2 -> The output folder does not exist"
    echo "3 -> No destination folder specified"
    echo "4 -> Failed to move"
    set "ExitCode=1"
    echo Exit code !ExitCode!
    exit /b !ExitCode!
)

if "%~1"=="--help" (
    echo Usage: move_utility.bat Source_Folder Destination_Folder fileName.fileExtension
    echo Moves all files from the source folder to the destination, handling file attributes.
    echo Termination codes:
    echo "0 -> Successful move"
    echo "1 -> Help displayed (-h or --help)"
    echo "2 -> The output folder does not exist"
    echo "3 -> No destination folder specified"
    echo "4 -> Failed to move"
    set "ExitCode=1"
    echo Exit code !ExitCode!
    exit /b !ExitCode!
)

rem Get parameters
set "SourceDir=%~1"
set "TargetDir=%~2"
rem Shifting for recursive reading fileNames
shift
shift

rem Check if source directory exists
if not exist "%SourceDir%" (
    echo Error: Source folder does not exist.
    set "ExitCode=2"
    echo Exit code %ExitCode%
    exit /b %ExitCode%
)

rem Validate input parameters
if "%TargetDir%"=="" (
    echo Error: Destination folder is not specified.
    set "ExitCode=3"
    echo Exit code !ExitCode!
    exit /b !ExitCode!
)

rem Create destination folder if it does not exist
if not exist "%TargetDir%" (
    mkdir "%TargetDir%"
)

rem Flag to check if specific files were given
set "SpecificFiles=0"

rem Function to move files with attribute handling
:move_file
set "FileToMove=%~1"
if "%FileToMove%"=="" goto check_all_files

set "SpecificFiles=1"

if exist "%SourceDir%\%FileToMove%" (

    rem Отримання атрибутів
    set "Hidden=" & set "ReadOnly=" & set "Archive="
    for /f "tokens=* delims=" %%A in ('attrib "%SourceDir%\%FileToMove%"') do (
        set "AttribLine=%%A"
    )

    for %%A in (!AttribLine!) do (
        if "%%A"=="H" set Hidden=H
        if "%%A"=="R" set ReadOnly=R
        if "%%A"=="A" set Archive=A
    )

    echo Moving file: %FileToMove% [!Hidden! !ReadOnly! !Archive!]

    rem Зняти прихованість, якщо є
    if defined Hidden attrib -H "%SourceDir%\%FileToMove%"
    rem Зняти ReadOnly, бо move не спрацює інакше
    if defined ReadOnly attrib -R "%SourceDir%\%FileToMove%"

    rem Перемістити файл
    move "%SourceDir%\%FileToMove%" "%TargetDir%\" > nul
    if errorlevel 1 (
        echo Failed to move: %FileToMove%
    ) else (
        echo Moved: %FileToMove%

        rem Після переміщення: повернути атрибути
        if defined Hidden attrib +H "%TargetDir%\%FileToMove%"
        if defined ReadOnly attrib +R "%TargetDir%\%FileToMove%"
        if not defined Archive attrib -A "%TargetDir%\%FileToMove%"
    )
    set "ExitCode=0"
    echo Exit code !ExitCode!
    exit /b !ExitCode!

) else (
    echo File not found: %FileToMove%
    set "ExitCode=4"
    echo Exit code !ExitCode!
    exit /b !ExitCode!
)

shift
goto move_file

:check_all_files
rem If no specific files were provided, move all files
if "%SpecificFiles%"=="0" (
    echo Moving all files from "%SourceDir%" to "%TargetDir%" with attributes...
    for /f "delims=" %%F in ('dir /a:-d /b "%SourceDir%"') do (
        set "FileName=%%F"
        set "Hidden=" & set "ReadOnly=" & set "Archive="

        for /f "tokens=* delims=" %%A in ('attrib "%SourceDir%\%%F"') do (
            set "AttribLine=%%A"
        )

        for %%A in (!AttribLine!) do (
            if "%%A"=="H" set Hidden=H
            if "%%A"=="R" set ReadOnly=R
            if "%%A"=="A" set Archive=A
        )

        echo Moving file: %%F [!Hidden! !ReadOnly! !Archive!]

        rem Зняти прихованість, якщо є
        if defined Hidden attrib -H "%SourceDir%\%%F"
        rem Зняти ReadOnly, бо move не спрацює інакше
        if defined ReadOnly attrib -R "%SourceDir%\%%F"
        move "%SourceDir%\%%F" "%TargetDir%\" > nul
        if errorlevel 1 (
            echo Failed to move: %%F
        ) else (
            echo Moved: %%F
            if defined Hidden attrib +H "%TargetDir%\%%F"
            if defined ReadOnly attrib +R "%TargetDir%\%%F"
            if not defined Archive attrib -A "%TargetDir%\%%F"
        )
    )
set "ExitCode=0"
echo Exit code !ExitCode!
exit /b !ExitCode!
)