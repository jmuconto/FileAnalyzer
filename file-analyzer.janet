# file-analyzer.janet - File System Analyzer and Categorizer

(import os)
(import io)

#-------------------------------------------
# File Categories
#-------------------------------------------

(def file-categories
  @{
    :images @["jpg" "jpeg" "png" "gif" "bmp" "tiff" "svg" "webp" "ico"]
    :documents @["pdf" "doc" "docx" "txt" "rtf" "odt" "tex" "md" "org"]
    :spreadsheets @["xls" "xlsx" "csv" "tsv" "ods"]
    :presentations @["ppt" "pptx" "odp" "key"]
    :archives @["zip" "tar" "gz" "bz2" "xz" "rar" "7z" "zst"]
    :audio @["mp3" "wav" "flac" "aac" "ogg" "m4a" "wma"]
    :video @["mp4" "avi" "mov" "mkv" "flv" "webm" "wmv"]
    :code @["py" "js" "ts" "rb" "go" "rs" "c" "cpp" "h" "java" "clj" "janet" "lisp" "lua" "vim" "sh" "bash" "fish"]
    :data @["json" "xml" "yaml" "yml" "toml" "ini" "conf" "log" "sql"]
    :executables @["exe" "msi" "dll" "so" "dylib" "bin"]
  })

#-------------------------------------------
# Size Categories
#-------------------------------------------

(def size-categories
  @{
    :tiny   [0 1024]                    ; < 1KB
    :small  [1024 (* 1024 10)]          ; 1KB - 10MB
    :medium [(* 1024 10) (* 1024 100)]  ; 10MB - 100MB
    :large  [(* 1024 100) (* 1024 500)] ; 100MB - 500MB
    :huge   [(* 1024 500) nil]          ; > 500MB
  })

#-------------------------------------------
# File Analysis Functions
#-------------------------------------------

# Get file extension
(defn get-extension [path]
  (def parts (string/split "." (os/path/basename path)))
  (if (> (length parts) 1)
    (last parts)
    ""))

# Get file size in bytes
(defn get-file-size [path]
  (try
    (os/stat path :size)
    ([err] nil)))

# Get file category based on extension
(defn categorize-by-type [path]
  (def ext (string/lower (get-extension path)))
  (var category "other")
  
  (each [cat exts] (pairs file-categories)
    (if (find |(= ext $) exts)
      (set category (string cat))))
  
  category)

# Get size category
(defn categorize-by-size [size]
  (var category "unknown")
  (if (nil? size)
    (set category "unknown")
    (each [cat [min max]] (pairs size-categories)
      (if (and (>= size min) (or (nil? max) (<= size max)))
        (set category (string cat)))))
  category)

# Human readable file size
(defn human-size [bytes]
  (if (nil? bytes)
    "N/A"
    (def units ["B" "KB" "MB" "GB" "TB"])
    (var size bytes)
    (var unit 0)
    (while (and (> size 1024) (< unit (dec (length units))))
      (set size (/ size 1024))
      (set unit (inc unit)))
    (string (int (math/floor (* size 10))) "/" "10 " (units unit))))

#-------------------------------------------
# Main Analysis Function
#-------------------------------------------

(defn analyze-directory [root-path]
  (def results @{
    :path root-path
    :total-files 0
    :total-size 0
    :directories 0
    :by-type @{}
    :by-size @{:tiny 0 :small 0 :medium 0 :large 0 :huge 0 :unknown 0}
    :by-name @{}
    :largest-file {:path "" :size 0}
    :smallest-file {:path "" :size math/inf}
    :files @[]
  })
  
  (defn walk-dir [dir]
    (try
      (each entry (os/dir dir)
        (def full-path (string dir "/" entry))
        (try
          (def stat (os/stat full-path))
          (cond
            (stat :directory)
            (do
              (set (results :directories) (inc (results :directories)))
              (walk-dir full-path))
            
            (stat :file)
            (do
              (def size (stat :size))
              (def ext (get-extension full-path))
              (def type-cat (categorize-by-type full-path))
              (def size-cat (categorize-by-size size))
              
              # Update totals
              (set (results :total-files) (inc (results :total-files)))
              (set (results :total-size) (+ (results :total-size) size))
              
              # Update by-type
              (def type-key (string/format "%s" type-cat))
              (update results :by-type type-key (fn [v] (if v (inc v) 1)))
              
              # Update by-size
              (def size-key (string size-cat))
              (update results :by-size size-key (fn [v] (if v (inc v) 1)))
              
              # Update by-name (extension)
              (if (> (length ext) 0)
                (update results :by-name ext (fn [v] (if v (inc v) 1))))
              
              # Track largest file
              (if (> size (results :largest-file :size))
                (set (results :largest-file) @{:path full-path :size size}))
              
              # Track smallest file
              (if (< size (results :smallest-file :size))
                (set (results :smallest-file) @{:path full-path :size size}))
              
              # Store file info
              (array/push (results :files) @{
                :path full-path
                :size size
                :size-human (human-size size)
                :extension ext
                :type category type-cat
                :size-category size-cat
              })))
          ([err] nil))))
      ([err] nil)))
  
  (walk-dir root-path)
  results)

#-------------------------------------------
# Report Generation
#-------------------------------------------

(defn print-report [results]
  (def path (results :path))
  (def total-files (results :total-files))
  (def total-size (results :total-size))
  (def directories (results :directories))
  (def largest (results :largest-file))
  (def smallest (results :smallest-file))
  
  (print "\n" (string/repeat "=" 60))
  (print "📊  File System Analysis Report")
  (print (string/repeat "=" 60))
  (print (string/format "Path: %s" path))
  (print (string/repeat "-" 60))
  
  # Overall statistics
  (print "\n📈  Overview:")
  (print (string/format "  Total Files:    %d" total-files))
  (print (string/format "  Total Size:     %s" (human-size total-size)))
  (print (string/format "  Directories:    %d" directories))
  
  # Size distribution
  (print "\n📏  Size Distribution:")
  (each [cat count] (pairs (results :by-size))
    (if (> count 0)
      (let [percentage (* 100 (/ count total-files))]
        (print (string/format "  %-10s: %6d files (%5.1f%%)" cat count percentage)))))
  
  # Type distribution
  (print "\n🗂️   Type Distribution:")
  (each [cat count] (pairs (results :by-type))
    (if (> count 0)
      (let [percentage (* 100 (/ count total-files))]
        (print (string/format "  %-12s: %6d files (%5.1f%%)" cat count percentage)))))
  
  # Top extensions
  (print "\n📁  Top 10 File Extensions:")
  (def sorted-extensions (sorted (results :by-name) >))
  (var ext-count 0)
  (each [ext count] sorted-extensions
    (if (< ext-count 10)
      (do
        (print (string/format "  .%-12s: %6d files" ext count))
        (set ext-count (inc ext-count)))))
  
  # Largest and smallest
  (print "\n🏆  Extreme Files:")
  (print (string/format "  Largest:  %s (%s)" 
          (os/path/basename (largest :path)) 
          (human-size (largest :size))))
  (print (string/format "  Smallest: %s (%s)" 
          (os/path/basename (smallest :path)) 
          (human-size (smallest :size))))
  
  # File listing by category
  (print "\n📋  Files by Category:")
  (def categories (distinct (map |($ :type) (results :files))))
  (each cat (sorted categories)
    (def files (filter |(= ($ :type) cat) (results :files)))
    (print (string/format "\n  %s (%d files):" cat (length files)))
    (each f (take 5 files)
      (print (string/format "    - %-30s %10s" 
              (os/path/basename (f :path))
              (f :size-human))))
    (if (> (length files) 5)
      (print (string/format "    ... and %d more" (- (length files) 5)))))
  
  (print "\n" (string/repeat "=" 60))
  (print "✅  Analysis Complete!")
  (print (string/repeat "=" 60) "\n"))

#-------------------------------------------
# Export to JSON
#-------------------------------------------

(defn export-json [results filename]
  (def json-data (json/encode results :pretty true))
  (def file (io/open filename :w))
  (:write file json-data)
  (:close file)
  (print (string/format "📄  Results exported to %s" filename)))

#-------------------------------------------
# CLI Interface
#-------------------------------------------

(defn main [& args]
  (def path (if (empty? args) "." (first args)))
  (def export-file (if (> (length args) 1) (args 1) nil))
  
  (print (string/format "🔍  Analyzing directory: %s" (os/path/abspath path)))
  (print "⏳  Please wait...\n")
  
  (def results (analyze-directory path))
  (print-report results)
  
  (if export-file
    (export-json results export-file))
  
  results)

#-------------------------------------------
# Example usage
#-------------------------------------------

# If run directly
(if (= (os/getenv "JANET_SCRIPT_FILE") (current-file))
  (do
    (def args (os/args))
    (if (> (length args) 1)
      (main (args 1) (args 2))
      (main))))

# Function to get file analysis without running CLI
(defn get-analysis [path]
  (analyze-directory path))

#--------------------------------------------------
# USAGE EXAMPLES:
#--------------------------------------------------
# 
# 1. Analyze current directory:
#    janet file-analyzer.janet
# 
# 2. Analyze specific directory:
#    janet file-analyzer.janet C:/Users/USER/Documents
# 
# 3. Analyze and export to JSON:
#    janet file-analyzer.janet C:/Users/USER/Documents report.json
# 
# 4. Use as a module:
#    (import file-analyzer)
#    (def results (file-analyzer/analyze-directory "."))