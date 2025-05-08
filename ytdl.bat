rem youtube-dl.exe --help > help.txt

rem yt-dlp.exe  -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best https://www.youtube.com/watch?v=EGIwcPA1_34

 yt-dlp  -U
rem yt-dlp  --external-downloader aria2c --playlist-start 31 https://www.youtube.com/watch?v=EGIwcPA1_34

rem yt-dlp.exe --embed-subs -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best  --merge-output-format mp4  -U https://www.youtube.com/watch?v=1cnQ3ek3EHg# 


rem yt-dlp --cookies-from-browser BROWSER

yt-dlp.exe --cookies-from-browser firefox --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" -f best "https://www.youtube.com/watch?v=ehABpw4Jf8g"




rem ffmpeg -i "https://www.youtube.com/watch?v=a7cc-HbCnGs" subtitles.srt

pause
rem yt-dlp "ytsearch:bv*[height<=1080][ext=mp4]+ba" ) to search YouTube
rem yt-dlp.exe  https://www.youtube.com/watch?v=1cnQ3ek3EHg#  --write-subs --write-auto-subs --sub-langs "en, en-orig" --embed-subs  --convert-subs srt --compat-options no-keep-subs   --embed-subs --write-auto-sub  --no-mtime --no-part  -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o  -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o C:\_downloads\\%(title)s-%(id)s.%(ext)s