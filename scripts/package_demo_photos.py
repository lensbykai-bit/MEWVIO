"""Bundle illustrative MEWVIO demo photos at APK build time.

Downloaded photos become local Android assets. If the image host is unavailable,
we package the MEWVIO icon as a safe offline placeholder instead of failing
the build or making the installed demo depend on connectivity.
"""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import shutil
import urllib.request

OUT = Path("assets/demo")
OUT.mkdir(parents=True, exist_ok=True)
ICON = Path("assets/images/app_icon.png")
IMAGES = {
    "hero_sunset.jpg": "photo-1470252649378-9c29740c9fa8",
    "portrait_luna.jpg": "photo-1524504388940-b1c1722653e1",
    "portrait_sophie.jpg": "photo-1534528741775-53994a69daeb",
    "portrait_kai.jpg": "photo-1500648767791-00dcc994a43e",
    "portrait_mina.jpg": "photo-1517841905240-472988babdf9",
    "portrait_anna.jpg": "photo-1524504388940-b1c1722653e1",
    "cat.jpg": "photo-1573865526739-10659fec78a5",
    "stars.jpg": "photo-1519608487953-e999c86e7455",
    "concert.jpg": "photo-1492684223066-81342ee5ff30",
    "music.jpg": "photo-1493225457124-a3eb161ffa5f",
    "gaming.jpg": "photo-1493711662062-fa541adb3fc8",
    "chill.jpg": "photo-1516280440614-37939bbacd81",
}

def fetch(item):
    name, photo_id = item
    dest = OUT / name
    try:
        request = urllib.request.Request(
            f"https://images.unsplash.com/{photo_id}?w=480&q=62&fit=crop",
            headers={"User-Agent": "MEWVIO-Demo/1.0"})
        with urllib.request.urlopen(request, timeout=9) as response:
            data = response.read(350000)
        if len(data) < 1000 or not data.startswith(bytes.fromhex("ffd8")):
            raise ValueError("Image endpoint did not return JPEG")
        dest.write_bytes(data)
        print(f"Bundled {name}: {len(data)} bytes")
    except Exception as exc:
        shutil.copyfile(ICON, dest)
        print(f"Offline logo fallback for {name}: {type(exc).__name__}")

with ThreadPoolExecutor(max_workers=6) as pool:
    list(pool.map(fetch, IMAGES.items()))

assert all((OUT / name).is_file() for name in IMAGES)
