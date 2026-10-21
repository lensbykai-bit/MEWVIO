"""Grant release APK internet access required by Supabase (idempotent)."""
from pathlib import Path
import xml.etree.ElementTree as ET

manifest = Path('android/app/src/main/AndroidManifest.xml')
text = manifest.read_text()
permission = 'android.permission.INTERNET'
if permission not in text:
    end = text.index('>') + 1
    text = text[:end] + f'\n    <uses-permission android:name="{permission}" />' + text[end:]
    manifest.write_text(text)

root = ET.fromstring(manifest.read_text())
assert any(
    child.get('{http://schemas.android.com/apk/res/android}name') == permission
    for child in root.findall('uses-permission')
), 'The release manifest must include internet access'
print('Release APK internet access verified')
