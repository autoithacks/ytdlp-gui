rem youtube-dl.exe --help > help.txt

rem yt-dlp.exe  -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best https://www.youtube.com/watch?v=EGIwcPA1_34

rem yt-dlp  -U
rem yt-dlp  --external-downloader aria2c --playlist-start 31 https://www.youtube.com/watch?v=EGIwcPA1_34

.\yt-dlp.exe  -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best   --merge-output-format mp4 https://www.youtube.com/watch?v=EGIwcPA1_34

pause
