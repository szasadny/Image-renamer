# 📸 Image Renamer & Date Adjuster

This batch script automates the process of renaming image files and adjusting their `DateTimeOriginal` metadata using [ExifTool](https://exiftool.org/). It scans specific subdirectories, renames images with a sequential counter, and modifies timestamps with random offsets. Ideal for organizing photo sets while maintaining chronological order.

---

## 🚀 Features

- 🔄 Renames images to a consistent format: `IMG_<counter>.jpg`.
- ⏰ Adjusts `DateTimeOriginal` metadata with random offsets (5–30 seconds).
- 🔍 Recursively scans all `0.1 Fotos` subfolders within the specified root directory.
- 🖱️ Interactive menu to:
  - Set the root directory.
  - Define the starting value for the global counter.
  - Start processing images.
- 💡 Uses ExifTool locally (no installation required if provided with the script).

---

## 📂 Folder Structure Requirements

This script is specficically made for the following folder structure:

```
root_folder
├── adres 1
  └── 0.1 Fotos
      ├── image1.jpg
      ├── image2.jpg
└── adres 2
  └── 0.1 Fotos
      ├── image3.jpg
      └── image4.jpg
```

---

## ⚡ Usage

1. **Clone or Download** the repository.
2. Place `exiftool.exe` and `exiftool_files` in the same directory as the script.
3. Run the script by right-clicking the (`.bat` file) -> run as administator.
4. Use the interactive menu to:
   - Set the root directory (defaults to the script’s directory).
   - Set the starting number for the image counter.
   - Start processing the images.

---

## 🔧 Dependencies

- [ExifTool](https://exiftool.org/): Ensure `exiftool.exe` and the `exiftool_files` folder are in the same directory as the script.