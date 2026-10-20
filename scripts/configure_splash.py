from pathlib import Path
import xml.etree.ElementTree as ET

root=Path("android/app/src/main/res")
values=root/"values"
values.mkdir(parents=True,exist_ok=True)
colors=values/"colors.xml"
colors.write_text("""<?xml version="1.0" encoding="utf-8"?>
<resources>
  <color name="mewvio_splash">#7653E8</color>
</resources>
""")
for path in [values/"styles.xml",root/"values-night"/"styles.xml"]:
    text=path.read_text()
    text=text.replace("@drawable/launch_background","@color/mewvio_splash")
    text=text.replace("android:windowBackground","android:windowBackground")
    path.write_text(text)
v31=root/"values-v31"
v31.mkdir(exist_ok=True)
(v31/"styles.xml").write_text("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowSplashScreenBackground">@color/mewvio_splash</item>
        <item name="android:windowSplashScreenAnimatedIcon">@mipmap/ic_launcher</item>
        <item name="android:windowSplashScreenIconBackgroundColor">@color/mewvio_splash</item>
        <item name="android:windowBackground">@color/mewvio_splash</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
""")
print("MEWVIO native purple splash screen configured")
