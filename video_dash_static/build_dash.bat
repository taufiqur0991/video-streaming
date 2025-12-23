@ECHO OFF
SET IN="../video_source/video.mp4"
SET OUT_TEMP="./temp_parts"
SET OUT_CONTENT="./content"

:: Buat folder jika belum ada
IF NOT EXIST %OUT_TEMP% mkdir %OUT_TEMP%
IF NOT EXIST %OUT_CONTENT% mkdir %OUT_CONTENT%

ECHO [1/2] Transcoding Video ke varian Bitrate...
:: Menggunakan NVENC (Nvidia) untuk kecepatan
ffmpeg -y -i %IN% ^
  -c:v h264_nvenc -b:v 2500k -g 48 -keyint_min 48 -sc_threshold 0 -vf "scale=-2:1080" -an %OUT_TEMP%/v1080.mp4 ^
  -c:v h264_nvenc -b:v 1000k -g 48 -keyint_min 48 -sc_threshold 0 -vf "scale=-2:720" -an %OUT_TEMP%/v720.mp4 ^
  -c:v h264_nvenc -b:v 500k -g 48 -keyint_min 48 -sc_threshold 0 -vf "scale=-2:480" -an %OUT_TEMP%/v480.mp4 ^
  -c:a aac -ab 128k -ar 48000 -vn %OUT_TEMP%/audio.mp4

ECHO [2/2] Packaging menjadi DASH Manifest...
packager-win-x64 ^
  input=%OUT_TEMP%/v1080.mp4,stream=video,output=%OUT_CONTENT%/v1080.mp4 ^
  input=%OUT_TEMP%/v720.mp4,stream=video,output=%OUT_CONTENT%/v720.mp4 ^
  input=%OUT_TEMP%/v480.mp4,stream=video,output=%OUT_CONTENT%/v480.mp4 ^
  input=%OUT_TEMP%/audio.mp4,stream=audio,output=%OUT_CONTENT%/audio.m4a ^
  --profile on-demand ^
  --mpd_output %OUT_CONTENT%/stream.mpd ^
  --min_buffer_time 2 ^
  --segment_duration 2

ECHO Selesai! File ada di folder /content
PAUSE