@echo off
setlocal enabledelayedexpansion

rem If the script is run without parameters, show usage message
if "%~1"=="" (
    echo Program for moving files. For help in usage print move_script_max.bat -h or move_script_max.bat --help
    cmd
)

rem Help handling
if "%~1"=="-h" (
    echo Usage: move_script_max.bat Source_Folder Destination_Folder fileName.fileExtension
    echo Moves all files from the source folder to the destination, handling file attributes.
    echo Termination codes:
    echo "0 -> Successful move"
    echo "1 -> Help displayed (-h or --help)"
    echo "2 -> The output folder does not exist"
    echo "3 -> No destination folder specified"
    exit /b 1
    echo Exit code %ERRORLEVEL%
)

if "%~1"=="--help" (
    echo Usage: move_script_max.bat Source_Folder Destination_Folder fileName.fileExtension
    echo Moves all files from the source folder to the destination, handling file attributes.
    echo Termination codes:
    echo "0 -> Successful move"
    echo "1 -> Help displayed (-h or --help)"
    echo "2 -> The output folder does not exist"
    echo "3 -> No destination folder specified"
    exit /b 1
    echo Exit code %ERRORLEVEL%
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
    exit /b 2
    echo Exit code %ERRORLEVEL%
)

rem Validate input parameters
if "%TargetDir%"=="" (
    echo Error: Destination folder is not specified.
    exit /b 3
    echo Exit code %ERRORLEVEL%
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
    rem Retrieve file attributes
    set "Attribs="
    for /f "tokens=1,2 delims= " %%A in ('attrib "%SourceDir%\%FileToMove%"') do set "Attribs=%%B"

    rem Display file information before moving
    echo Moving file: %FileToMove% [!Attribs!]

    rem Temporarily remove hidden attribute
    attrib -h "%SourceDir%\%FileToMove%"

    move "%SourceDir%\%FileToMove%" "%TargetDir%\" > nul

    rem Restore original attributes
    attrib +h "%TargetDir%\%FileToMove%" > nul 2>&1
    if not "!Attribs:~0,1!"=="H" attrib -h "%TargetDir%\%FileToMove%"
    if not "!Attribs:~1,1!"=="R" attrib -r "%TargetDir%\%FileToMove%"
    if not "!Attribs:~2,1!"=="A" attrib -a "%TargetDir%\%FileToMove%"
    
    echo Moved: %FileToMove%
) else (
    echo File not found: %FileToMove%
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

    if defined Hidden attrib -H "%SourceDir%\%%F"
    move "%SourceDir%\%%F" "%TargetDir%\" > nul
    if errorlevel 1 (
        echo Failed to move: %%F
    ) else (
        echo Moved: %%F
        if defined Hidden attrib +H "%TargetDir%\%%F"
    )
)
)

rem Completion message
echo Files have been moved to "%TargetDir%".
exit /b 0
echo Exit code %ERRORLEVEL%