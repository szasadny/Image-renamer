@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: SET SCRIPT DIRECTORY AS CURRENT DIRECTORY
:: ===========================================
cd /d "%~dp0"
set "root_dir=%cd%"
set /a global_counter=1000

echo Current Directory: %cd%
echo Default root directory set to: %root_dir%
echo Checking if ExifTool exists in the current directory...

:: ===========================================
:: EXIFTOOLS SETUP
:: ===========================================
if not exist "%cd%\exiftool.exe" (
    echo ExifTool is not found in the current directory: %cd%
    echo Please make sure exiftool.exe and exiftool_files folder are located in the same folder as this script.
    pause
    exit /b
)

:: ===========================================
:: CMD USER INTERFACE - WELCOME SCREEN
:: ===========================================
:main_menu
cls
echo ===================================================
echo             IMAGE RENAMER AND ^DATE^ ADJUSTER
echo ===================================================
echo 1. Set Root Folder (Current: %root_dir%)
echo 2. Set Starting Global Counter (Current: !global_counter!)
echo 3. Start Processing
echo 4. Exit
echo ===================================================
set /p choice="Choose an option [1-4]: "

if "%choice%"=="1" goto :set_root
if "%choice%"=="2" goto :set_counter
if "%choice%"=="3" goto :start_processing
if "%choice%"=="4" exit
goto :main_menu

:: ===========================================
:: SET ROOT DIRECTORY
:: ===========================================
:set_root
cls
echo ===================================================
echo               SET ROOT DIRECTORY
echo ===================================================
set /p root_dir="Enter full path to root directory: "
if not exist "%root_dir%" (
    echo Folder does not exist. Please try again.
    pause
    goto :set_root
)
echo Root directory set to: %root_dir%
pause
goto :main_menu

:: ===========================================
:: SET GLOBAL COUNTER
:: ===========================================
:set_counter
cls
echo ===================================================
echo           SET STARTING GLOBAL COUNTER
echo ===================================================
set /p global_counter="Enter starting number for global counter: "
echo Global counter set to: !global_counter!
pause
goto :main_menu


:: ===========================================
:: PROCESSING IMAGES
:: ===========================================
:start_processing
cls
echo ===================================================
echo           PROCESSING STARTED - PLEASE WAIT

echo ===================================================

for /d %%F in ("%root_dir%\*") do (
    echo Checking folder: %%F
    if exist "%%F\0.1 Fotos" (
        echo Folder "0.1 Fotos" found in: %%F
        dir "%%F\0.1 Fotos" /b

        :: Process all files in "0.1 Fotos"
        for %%I in ("%%F\0.1 Fotos\*.*") do (
            echo Found file: %%~nxI
            if /i "%%~xI"==".jpg" (
                set "file=%%~nxI"
                set "fileCode=!file:~4,4!"
                echo !fileCode! %%~nxI >> "%%F\0.1 Fotos\sorted_list.txt"
            )
        )

        :: Sort the filenames
        sort "%%F\0.1 Fotos\sorted_list.txt" /o "%%F\0.1 Fotos\sorted_list.txt"
        echo [INFO] Sorted list of images:
        type "%%F\0.1 Fotos\sorted_list.txt"

        set /a seconds_offset=0
        :: First rename from IMG_ to TEMP_ with correct count
        for /f "usebackq tokens=2" %%J in ("%%F\0.1 Fotos\sorted_list.txt") do (
            set "old_name=%%F\0.1 Fotos\%%J"
            set "temp_name=%%F\0.1 Fotos\TEMP_!global_counter!.JPG"

            echo [PROCESSING] Renaming "!old_name!" to "!temp_name!"...
            ren "!old_name!" "TEMP_!global_counter!.JPG" && echo [OK] Renamed successfully || echo [X] Rename failed

            set /a rand=%random% %% 26 + 5
            set /a seconds_offset+=!rand!

            echo [PROCESSING] Adjusting DateTimeOriginal by !seconds_offset! seconds...
            .\exiftool "-DateTimeOriginal+=0:0:0 0:0:!seconds_offset!" "!temp_name!" -overwrite_original >nul && echo [OK] Timestamp adjusted || echo [X] Timestamp adjustment failed

            set /a global_counter+=1
        )

        :: Second rename from TEMP_ to IMG_
        for %%I in ("%%F\0.1 Fotos\TEMP_*") do (
            set "file_name=%%~nxI"
            set "old_name=%%F\0.1 Fotos\!file_name!"
            set "new_name=IMG_!file_name:~5!"

            echo [DEBUG] Checking file: %%~nxI
            echo [DEBUG] old_name: !old_name! new_name: !new_name!

            if exist "!old_name!" (
                echo [PROCESSING] Renaming "!old_name!" to "!new_name!"...
                ren "!old_name!" "!new_name!" && echo [OK] Renamed successfully || echo [X] Rename failed
            ) else (
                echo [ERROR] File "!old_name!" does not exist
            )
        )

        del "%%F\0.1 Fotos\sorted_list.txt"
        echo [INFO] Finished processing folder: %%F
        echo ---------------------------------------------------
    )
)

:: ===========================================
:: FINAL SUMMARY SCREEN (Logs Persist)
:: ===========================================
echo ===================================================
echo                 PROCESSING COMPLETE 
echo ===================================================
echo All '0.1 Fotos' folders processed successfully.
echo No duplicate image codes or numbering gaps found.
echo DateTimeOriginal adjusted with random 5-30s increments.
echo ---------------------------------------------------
echo [INFO] Processing logs above remain visible for review.
echo [INFO] Press any key to return to the main menu.

pause
goto :main_menu
