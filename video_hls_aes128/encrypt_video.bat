@echo off
SETLOCAL
if not exist "encrypted_video" mkdir "encrypted_video"

:: Menggunakan asplit untuk menduplikasi audio agar tidak bentrok di mapping
ffmpeg -i "../video_source/video.mp4" ^
  -filter_complex "[0:v]split=3[v1][v2][v3]; [v1]scale=w=1920:h=1080[v1out]; [v2]scale=w=1280:h=720[v2out]; [v3]scale=w=640:h=360[v3out]; [0:a]asplit=3[a1][a2][a3]" ^
  -map "[v1out]" -c:v:0 libx264 -b:v:0 3000k -g 48 -keyint_min 48 -sc_threshold 0 ^
  -map "[v2out]" -c:v:1 libx264 -b:v:1 1500k -g 48 -keyint_min 48 -sc_threshold 0 ^
  -map "[v3out]" -c:v:2 libx264 -b:v:2 600k -g 48 -keyint_min 48 -sc_threshold 0 ^
  -map "[a1]" -c:a:0 aac -b:a:0 128k ^
  -map "[a2]" -c:a:1 aac -b:a:1 128k ^
  -map "[a3]" -c:a:2 aac -b:a:2 128k ^
  -f hls ^
  -hls_time 10 ^
  -hls_key_info_file keys/key_info.txt ^
  -hls_playlist_type vod ^
  -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" ^
  -master_pl_name master.m3u8 ^
  -hls_segment_filename "encrypted_video/v%%v_seg_%%03d.ts" ^
  "encrypted_video/v%%v_index.m3u8"

echo.
echo Selesai! Master playlist siap digunakan.
pause