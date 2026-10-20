#!/usr/bin/env bash
set -euo pipefail
mkdir -p assets/videos
if ! command -v ffmpeg >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq ffmpeg
fi
# Lightweight offline motion clips: no third-party video streams or network access.
declare -a colors=("0x4D20A8" "0x137CC1" "0x9A267E")
declare -a titles=("MEWVIO" "GOOD VIBES" "MEET FRIENDS")
for i in 1 2 3; do
  index=$((i-1))
  color="${colors[$index]}"
  title="${titles[$index]}"
  ffmpeg -hide_banner -loglevel error -y \
    -f lavfi -i "color=c=${color}:s=360x640:r=24:d=5" \
    -vf "drawtext=text='${title}':fontcolor=white:fontsize=37:x=(w-text_w)/2:y=h/2-45,drawtext=text='Meet. Watch. Vibe.':fontcolor=white:fontsize=20:x=(w-text_w)/2:y=h/2+12,drawbox=x=0:y=545:w=360:h=5:color=0xEF68CF:t=fill" \
    -c:v libx264 -preset ultrafast -pix_fmt yuv420p -crf 30 -movflags +faststart \
    -an "assets/videos/mewvio_${i}.mp4"
done
ls -lh assets/videos
