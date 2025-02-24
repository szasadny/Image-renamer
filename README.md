# 📸 Image Renamer & Date Adjuster

This batch script automates the process of renaming image files and adjusting their `FileCreateDate` and `FileModifyDate` metadata using [ExifTool](https://exiftool.org/). It scans specified subdirectories, renames images sequentially, and adjusts timestamps with random increments. Ideal for organizing photo sets while maintaining chronological order and adjusting timestamps incrementally for unique date data.

---

## 🚀 Features

- 🔄 Renames images to a consistent format: `IMG_<counter>.jpg`.
- ⏰ Adjusts `FileCreateDate` and `FileModifyDate` metadata with random offsets (30–60 seconds).
- 🔍 Recursively scans all `01 Foto's` subfolders within the specified root directory.
- 🖱️ Interactive menu to:
  - Set the root directory.
  - Toggle logging to monitor the script’s actions.
  - Start processing images.
  - Exit the script.
- 💡 Uses ExifTool locally (no installation required if provided with the script).

---

## 📂 Folder Structure Requirements

This script is made for the following folder structure:

```
root_folder
├── subfolder_1
│   └── ...
│       └── subfolder_1_X
│           └── 01 Foto's
│               ├── IMG_1001.jpg
│               ├── IMG_1003.jpg
└── subfolder_2
    └── ...
        └── subfolder_2_X
            └── 01 Foto's
                ├── IMG_1002.jpg
                ├── IMG_1005.jpg

```

---

## ⚡ Usage

1. **Clone or Download** the repository.
2. Place `exiftool.exe` and `exiftool_files` in the same directory as the script.
3. Run the script by right-clicking the `.bat` file and selecting *Run as administrator*.
4. Use the interactive menu to:
   - Set the root directory (defaults to the script’s directory).
   - Toggle logging to track script progress.
   - Start processing the images.

---

## 🔧 Dependencies

- [ExifTool](https://exiftool.org/): Ensure `exiftool.exe` and the `exiftool_files` folder are in the same directory as the script.
