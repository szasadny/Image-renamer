@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: SET SCRIPT DIRECTORY AS CURRENT DIRECTORY
:: ===========================================
cd /d "%~dp0"
set "root_dir=%cd%"
set "logging=OFF"
set "folder_name=01. Foto's"

echo Current Directory: %cd%
echo Default root directory set to: %root_dir%
@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: SET SCRIPT DIRECTORY AS CURRENT DIRECTORY
:: ===========================================
cd /d "%~dp0"
set "root_dir=%cd%"
set "logging=OFF"
set "folder_name=01. Foto's"

echo Current Directory: %cd%
echo Default root directory set to: %root_dir%
echo Default folder name set to: %folder_name%
echo Checking if ExifTool exists in the current directory...

:: ===========================================
:: EXIFTOOLS SETUP
:: ===========================================
if not exist "%cd%\\exiftool.exe" (
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
echo             IMAGE RENAMER AND DATE ADJUSTER
echo ===================================================
echo 1. Set Root Folder (Current: %root_dir%)
echo 2. Toggle Logging (Current: %logging%)
echo 3. Set Photos Folder Name (Current: %folder_name%)
echo 4. Start Processing
echo 5. Exit
echo ===================================================
set /p choice="Choose an option [1-5]: "

if "%choice%"=="1" goto :set_root
if "%choice%"=="2" goto :toggle_logging
if "%choice%"=="3" goto :set_folder_name
if "%choice%"=="4" goto :start_processing
if "%choice%"=="5" exit
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
goto :main_menu

:: ===========================================
:: TOGGLE LOGGING
:: ===========================================
:toggle_logging
if "%logging%"=="ON" (
    set "logging=OFF"
) else (
    set "logging=ON"
)
echo Logging is now %logging%.
goto :main_menu

:: ===========================================
:: SET FOLDER NAME
:: ===========================================
:set_folder_name
cls
echo ===================================================
echo               SET FOLDER NAME
echo ===================================================
set /p folder_name="Enter folder name (current: %folder_name%): "
echo Folder name set to: %folder_name%
goto :main_menu

:: ===========================================
:: PROCESSING IMAGES
:: ===========================================
:start_processing
cls
echo ===================================================
echo           PROCESSING STARTED - PLEASE WAIT
echo ===================================================

for /r "%root_dir%" %%F in (.) do (
    if exist "%%F\\%folder_name%" (
        if "%logging%"=="ON" echo Folder "%folder_name%" found in: %%F

        (for %%I in ("%%F\\%folder_name%\\IMG_*.JPG") do (
            set "file=%%~nxI"
            set "fileCode=!file:~4,4!"
            echo !fileCode!
        )) > "%%F\\%folder_name%\\sorted_list.txt"

        sort "%%F\\%folder_name%\\sorted_list.txt" /o "%%F\\%folder_name%\\sorted_list.txt"

        set "start_code="
        set "base_create_datetime="
        set "base_modify_datetime="
        set /a seconds_offset=0

        for /f "usebackq tokens=1" %%C in ("%%F\\%folder_name%\\sorted_list.txt") do (
            if not defined start_code set /a start_code=%%C
        )

        if "%logging%"=="ON" echo [INFO] Starting code for folder: !start_code!

        :: Loop through each image in the folder
        for /f "usebackq tokens=*" %%C in ("%%F\\%folder_name%\\sorted_list.txt") do (
            set "image_file=%%F\\%folder_name%\\IMG_%%C.JPG"
            if "%logging%"=="ON" echo [INFO] Processing file: !image_file!

            :: Check if the file exists before processing
            if exist "!image_file!" (
                if not defined base_create_datetime (
					:: Extract Base datetime (first image)
					for /f "delims=" %%a in ('exiftool -s -s -s -FileCreateDate "!image_file!"') do (
						set "base_create_datetime=%%a"
					)
					for /f "delims=" %%a in ('exiftool -s -s -s -FileModifyDate "!image_file!"') do (
						set "base_modify_datetime=%%a"
					)
					for /f "delims=" %%a in ('exiftool -s -s -s -DateTimeOriginal "!image_file!"') do (
						set "base_original_datetime=%%a"
					)
					for /f "delims=" %%a in ('exiftool -s -s -s -CreateDate "!image_file!"') do (
						set "base_create_date_datetime=%%a"
					)
					for /f "delims=" %%a in ('exiftool -s -s -s -ModifyDate "!image_file!"') do (
						set "base_modify_date_datetime=%%a"
					)
					:: Add logging for these base datetime values
					if "%logging%"=="ON" (
						echo [INFO] Base FileCreateDate: !base_create_datetime!
						echo [INFO] Base FileModifyDate: !base_modify_datetime!
						echo [INFO] Base DateTimeOriginal: !base_original_datetime!
						echo [INFO] Base CreateDate: !base_create_date_datetime!
						echo [INFO] Base ModifyDate: !base_modify_date_datetime!
					)
                ) else (
                    :: Generate random offset (30-60 seconds) for each new image
                    set /a rand=%random% %% 31 + 30
                    set /a seconds_offset+=!rand!

                    if "%logging%"=="ON" echo [INFO] Adjusting create datetime for image: %%C by !seconds_offset! seconds...

                    :: Process CreateDate with separate overflow handling
                    for /f "tokens=1,2 delims= " %%b in ("!base_create_datetime!") do (
                        set "date_part_create=%%b"
                        set "time_part_create=%%c"
                    )

                    for /f "tokens=1-4 delims=:.+-" %%d in ("!time_part_create!") do (
                        set "hour_create=%%d"
                        set "minute_create=%%e"
                        set "second_create=%%f"
                        set "gmt_offset_hours=%%g"
                    )

                    :: Add offset to seconds
                    set /a second_create+=!seconds_offset!

                    :: Handle seconds overflow for CreateDate (if seconds exceed 60)
                    if !second_create! geq 60 (
                        set /a minute_create+=!second_create!/60
                        set /a second_create=!second_create!%%60
                    )

                    :: Handle minutes overflow for CreateDate (if minutes exceed 60)
                    if !minute_create! geq 60 (
                        set /a hour_create+=!minute_create!/60
                        set /a minute_create=!minute_create!%%60
                    )

                    :: Handle hours overflow for CreateDate (if hours exceed 24)
                    if !hour_create! geq 24 (
                        set /a hour_create=!hour_create!%%24
                    )

					:: Pad values with leading zeros if necessary
					for /f "tokens=* delims=0" %%x in ("!hour_create!") do set "hour_create=%%x"
					if !hour_create! lss 10 set "hour_create=0!hour_create!"

					for /f "tokens=* delims=0" %%x in ("!minute_create!") do set "minute_create=%%x"
					if !minute_create! lss 10 set "minute_create=0!minute_create!"

					for /f "tokens=* delims=0" %%x in ("!second_create!") do set "second_create=%%x"
					if !second_create! lss 10 set "second_create=0!second_create!"

                    :: Rebuild new time string for FileCreateDate with GMT offset
                    set "new_time_create=!hour_create!:!minute_create!:!second_create!+!gmt_offset_hours!:00"
                    set "new_create_datetime=!date_part_create! !new_time_create!"

                    if "%logging%"=="ON" echo [INFO] New FileCreateDate: !new_create_datetime!

                    :: Apply the new datetime to FileCreateDate
                    exiftool -FileCreateDate="!new_create_datetime!" "!image_file!" -overwrite_original >nul

                    :: Process ModifyDate with separate overflow handling
                    for /f "tokens=1,2 delims= " %%b in ("!base_modify_datetime!") do (
                        set "date_part_modify=%%b"
                        set "time_part_modify=%%c"
                    )

                    for /f "tokens=1-4 delims=:.+-" %%d in ("!time_part_modify!") do (
                        set "hour_modify=%%d"
                        set "minute_modify=%%e"
                        set "second_modify=%%f"
                        set "gmt_offset_hours=%%g"
                    )

                    :: Add offset to seconds for ModifyDate
                    set /a second_modify+=!seconds_offset!

                    :: Handle seconds overflow for ModifyDate (if seconds exceed 60)
                    if !second_modify! geq 60 (
                        set /a minute_modify+=!second_modify!/60
                        set /a second_modify=!second_modify!%%60
                    )

                    :: Handle minutes overflow for ModifyDate (if minutes exceed 60)
                    if !minute_modify! geq 60 (
                        set /a hour_modify+=!minute_modify!/60
                        set /a minute_modify=!minute_modify!%%60
                    )

                    :: Handle hours overflow for ModifyDate (if hours exceed 24)
                    if !hour_modify! geq 24 (
                        set /a hour_modify=!hour_modify!%%24
                    )

					:: Pad values with leading zeros if necessary
					for /f "tokens=* delims=0" %%x in ("!hour_modify!") do set "hour_modify=%%x"
					if !hour_modify! lss 10 set "hour_modify=0!hour_modify!"

					for /f "tokens=* delims=0" %%x in ("!minute_modify!") do set "minute_modify=%%x"
					if !minute_modify! lss 10 set "minute_modify=0!minute_modify!"

					for /f "tokens=* delims=0" %%x in ("!second_modify!") do set "second_modify=%%x"
					if !second_modify! lss 10 set "second_modify=0!second_modify!"

                    :: Rebuild new time string for FileModifyDate with GMT offset
                    set "new_time_modify=!hour_modify!:!minute_modify!:!second_modify!+!gmt_offset_hours!:00"
                    set "new_modify_datetime=!date_part_modify! !new_time_modify!"

                    if "%logging%"=="ON" echo [INFO] New FileModifyDate: !new_modify_datetime!

                    :: Apply the new datetime to FileModifyDate
                    exiftool -FileModifyDate="!new_modify_datetime!" "!image_file!" -overwrite_original >nul
					
					
					:: Process for DateTimeOriginal (base_original_datetime)
					for /f "tokens=1,2 delims= " %%b in ("!base_original_datetime!") do (
						set "date_part_original=%%b"
						set "time_part_original=%%c"
					)

					for /f "tokens=1-4 delims=:.+-" %%d in ("!time_part_original!") do (
						set "hour_original=%%d"
						set "minute_original=%%e"
						set "second_original=%%f"
					)

					set /a second_original+=!seconds_offset!

					:: Handle overflow for seconds to minutes and hours
					if !second_original! geq 60 (
						set /a minute_original+=!second_original!/60
						set /a second_original=!second_original!%%60
					)
					if !minute_original! geq 60 (
						set /a hour_original+=!minute_original!/60
						set /a minute_original=!minute_original!%%60
					)
					if !hour_original! geq 24 (
						set /a hour_original=!hour_original!%%24
					)

					:: Pad values with leading zeros if necessary
					for /f "tokens=* delims=0" %%x in ("!hour_original!") do set "hour_original=%%x"
					if !hour_original! lss 10 set "hour_original=0!hour_original!"

					for /f "tokens=* delims=0" %%x in ("!minute_original!") do set "minute_original=%%x"
					if !minute_original! lss 10 set "minute_original=0!minute_original!"

					for /f "tokens=* delims=0" %%x in ("!second_original!") do set "second_original=%%x"
					if !second_original! lss 10 set "second_original=0!second_original!"

					:: Rebuild the adjusted Date/Time Original
					set "new_original_datetime=!date_part_original! !hour_original!:!minute_original!:!second_original!"
					
					if "%logging%"=="ON" echo [INFO] New DateTimeOriginal: !new_original_datetime!

					:: Apply the new Date/Time Original
					exiftool -DateTimeOriginal="!new_original_datetime!" "!image_file!" -overwrite_original >nul

					:: Process for FileCreateDate (base_create_date)
					for /f "tokens=1,2 delims= " %%b in ("!base_create_date!") do (
						set "date_part_create=%%b"
						set "time_part_create=%%c"
					)

					for /f "tokens=1-4 delims=:.+-" %%d in ("!time_part_create!") do (
						set "hour_create=%%d"
						set "minute_create=%%e"
						set "second_create=%%f"
					)

					set /a second_create+=!seconds_offset!

					:: Handle overflow for seconds to minutes and hours
					if !second_create! geq 60 (
						set /a minute_create+=!second_create!/60
						set /a second_create=!second_create!%%60
					)
					if !minute_create! geq 60 (
						set /a hour_create+=!minute_create!/60
						set /a minute_create=!minute_create!%%60
					)
					if !hour_create! geq 24 (
						set /a hour_create=!hour_create!%%24
					)

					:: Pad values with leading zeros if necessary
					for /f "tokens=* delims=0" %%x in ("!hour_create!") do set "hour_create=%%x"
					if !hour_create! lss 10 set "hour_create=0!hour_create!"

					for /f "tokens=* delims=0" %%x in ("!minute_create!") do set "minute_create=%%x"
					if !minute_create! lss 10 set "minute_create=0!minute_create!"

					for /f "tokens=* delims=0" %%x in ("!second_create!") do set "second_create=%%x"
					if !second_create! lss 10 set "second_create=0!second_create!"

					:: Rebuild the adjusted CreateDate
					set "new_create_datetime=!date_part_create! !hour_create!:!minute_create!:!second_create!"
					
					if "%logging%"=="ON" echo [INFO] New FileCreateDate: !new_create_datetime!

					:: Apply the new FileCreateDate
					exiftool -FileCreateDate="!new_create_datetime!" "!image_file!" -overwrite_original >nul

					:: Process for FileModifyDate (base_modify_date)
					for /f "tokens=1,2 delims= " %%b in ("!base_modify_date!") do (
						set "date_part_modify=%%b"
						set "time_part_modify=%%c"
					)

					for /f "tokens=1-4 delims=:.+-" %%d in ("!time_part_modify!") do (
						set "hour_modify=%%d"
						set "minute_modify=%%e"
						set "second_modify=%%f"
					)

					set /a second_modify+=!seconds_offset!

					:: Handle overflow for seconds to minutes and hours
					if !second_modify! geq 60 (
						set /a minute_modify+=!second_modify!/60
						set /a second_modify=!second_modify!%%60
					)
					if !minute_modify! geq 60 (
						set /a hour_modify+=!minute_modify!/60
						set /a minute_modify=!minute_modify!%%60
					)
					if !hour_modify! geq 24 (
						set /a hour_modify=!hour_modify!%%24
					)

					:: Pad values with leading zeros if necessary
					for /f "tokens=* delims=0" %%x in ("!hour_modify!") do set "hour_modify=%%x"
					if !hour_modify! lss 10 set "hour_modify=0!hour_modify!"

					for /f "tokens=* delims=0" %%x in ("!minute_modify!") do set "minute_modify=%%x"
					if !minute_modify! lss 10 set "minute_modify=0!minute_modify!"

					for /f "tokens=* delims=0" %%x in ("!second_modify!") do set "second_modify=%%x"
					if !second_modify! lss 10 set "second_modify=0!second_modify!"

					:: Rebuild the adjusted ModifyDate
					set "new_modify_datetime=!date_part_modify! !hour_modify!:!minute_modify!:!second_modify!"
					
					if "%logging%"=="ON" echo [INFO] New FileModifyDate: !new_modify_datetime!

					:: Apply the new FileModifyDate
					exiftool -FileModifyDate="!new_modify_datetime!" "!image_file!" -overwrite_original >nul
                )

                :: Renaming images
                set "old_name=!image_file!"
                set "new_name=%%F\\%folder_name%\\TEMP_!start_code!.JPG"
                if "%logging%"=="ON" echo [INFO] Renaming "!old_name!" to "!new_name!"...
                ren "!old_name!" "TEMP_!start_code!.JPG"
                set /a start_code+=1
            ) else (
                if "%logging%"=="ON" echo [ERROR] File not found: !image_file!
            )
        )

        for %%I in ("%%F\\%folder_name%\\TEMP_*") do (
            set "file_name=%%~nxI"
            set "old_name=%%F\\%folder_name%\\!file_name!"
            set "new_name=IMG_!file_name:~5!"

            if "%logging%"=="ON" echo [INFO] Renaming "!old_name!" to "!new_name!"...
            ren "!old_name!" "!new_name!"
        )

        del "%%F\\%folder_name%\\sorted_list.txt"
        if "%logging%"=="ON" echo [INFO] Finished processing folder: %%F
    )
)

echo ===================================================
echo                 PROCESSING COMPLETE
echo ===================================================
echo All '%folder_name%' folders processed successfully, using the correct lowest image code per folder.
echo FileCreateDate adjusted starting from the base datetime with incremental random seconds.
echo FileModifyDate adjusted starting from the base datetime with incremental random seconds.
echo ---------------------------------------------------
echo [INFO] Press any key to return to the main menu.

pause
goto :main_menu