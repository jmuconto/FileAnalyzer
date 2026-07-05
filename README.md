# FileAnalyzer
A file system analysis tool written in Janet that scans directories and categorizes files by type, size, and name.
# Analyze current directory
janet file-analyzer.janet

# Analyze specific directory
janet file-analyzer.janet /path/to/folder

# Export results to JSON
janet file-analyzer.janet /path/to/folder report.json

# Use forward slashes
janet file-analyzer.janet C:/Users/USER/Documents

# Or escaped backslashes
janet file-analyzer.janet C:\\Users\\USER\\Documents

============================================================
📊  File System Analysis Report
============================================================
Path: /home/user/Documents
------------------------------------------------------------

📈  Overview:
  Total Files:    342
  Total Size:     2.45 GB
  Directories:    12

📏  Size Distribution:
  tiny      :    156 files (45.6%)
  small     :    124 files (36.3%)
  medium    :     45 files (13.2%)
  large     :     12 files (3.5%)
  huge      :      5 files (1.5%)

🗂️   Type Distribution:
  images     :     78 files (22.8%)
  documents  :    145 files (42.4%)
  code       :     67 files (19.6%)
  archives   :     12 files (3.5%)
  other      :     40 files (11.7%)

📁  Top 10 File Extensions:
  .pdf        :     56 files
  .txt        :     42 files
  .jpg        :     34 files
  .py         :     28 files
  .md         :     23 files
  .png        :     18 files
  .json       :     16 files
  .zip        :     12 files
  .js         :     11 files
  .csv        :      9 files

🏆  Extreme Files:
  Largest:  movie.mp4 (2.1 GB)
  Smallest: config.ini (128 bytes)

📋  Files by Category:

  archives (12 files):
    - project-backup.zip                1.5 GB
    - data.tar.gz                     45.3 MB
    - images.zip                      12.7 MB
    - logs.tar.bz2                    8.2 MB
    - config.zip                      2.1 MB
    ... and 7 more

  code (67 files):
    - main.py                       128.5 KB
    - utils.janet                   45.2 KB
    - server.js                     32.8 KB
    - styles.css                     8.4 KB
    - config.json                    2.1 KB
    ... and 62 more

============================================================
✅  Analysis Complete!
============================================================

# Installation
## Option 1: Download the Script
bash
curl -o file-analyzer.janet https://raw.githubusercontent.com/yourusername/file-analyzer/main/file-analyzer.janet
## Option 2: Clone the Repository
bash##
git clone https://github.com/yourusername/file-analyzer.git
cd file-analyzer
