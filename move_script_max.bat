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
    echo "1 -> Help displayed (-h ��� --help)"
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
    echo "1 -> Help displayed (-h ��� --help)"
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
    attrib "%SourceDir%\%FileToMove%" > nul
    set "Hidden="
    set "ReadOnly="
    set "Archive="

    for /f "tokens=2 delims= " %%A in ('attrib "%SourceDir%\%FileToMove%"') do (
        if "%%A"=="H" set "Hidden=Hidden"
        if "%%A"=="R" set "ReadOnly=ReadOnly"
        if "%%A"=="A" set "Archive=Archive"
    )

    rem Display file information before moving
    echo Moving file: %FileToMove% [!Hidden! !ReadOnly! !Archive!]

    move "%SourceDir%\%FileToMove%" "%TargetDir%\" > nul
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
        for %%F in ("%SourceDir%\*") do (
            attrib "%%F" > nul
            set "Hidden="
            set "ReadOnly="
            set "Archive="

            for /f "tokens=2 delims= " %%A in ('attrib "%%F"') do (
                if "%%A"=="H" set "Hidden=Hidden"
                if "%%A"=="R" set "ReadOnly=ReadOnly"
                if "%%A"=="A" set "Archive=Archive"
            )

            echo Moving file: %%~nxF [!Hidden! !ReadOnly! !Archive!]
            move "%%F" "%TargetDir%\" > nul
        )
    )

rem Completion message
echo Files have been moved to "%TargetDir%".
exit /b 0
echo Exit code %ERRORLEVEL%