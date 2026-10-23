"""Configure consent-based camera recording & legacy gallery export on Android."""
from pathlib import Path
import xml.etree.ElementTree as ET

path = Path('android/app/src/main/AndroidManifest.xml')
text = path.read_text()
needed = [
    '<uses-permission android:name="android.permission.CAMERA" />',
    '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
    '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />',
]
for line in needed:
    permission = line.split('android:name="')[1].split('"')[0]
    if permission not in text:
        pos = text.index('>') + 1
        text = text[:pos] + '\n    ' + line + text[pos:]
path.write_text(text)
root = ET.fromstring(text)
namespace = '{http://schemas.android.com/apk/res/android}'
found = {element.get(namespace+'name') for element in root.findall('uses-permission')}
assert {'android.permission.CAMERA','android.permission.RECORD_AUDIO',
        'android.permission.WRITE_EXTERNAL_STORAGE'}.issubset(found)
print('Camera, microphone and legacy media permissions configured')
