"""Add alternative Maven mirrors before Gradle's default repositories.

Only used during the GitHub Actions build. Flutter application code is unchanged.
"""
from pathlib import Path
import os

mirror_lines = """
    maven(url = "https://maven.aliyun.com/repository/public")
    maven(url = "https://maven.aliyun.com/repository/google")
    maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
    maven(url = "https://maven-central.storage-download.googleapis.com/maven2/")
"""

flutter_root = Path(os.environ["FLUTTER_ROOT"])
targets = [
    Path("android/settings.gradle.kts"),
    Path("android/build.gradle.kts"),
    flutter_root / "packages/flutter_tools/gradle/settings.gradle.kts",
    flutter_root / "packages/flutter_tools/gradle/build.gradle.kts",
]
for file in targets:
    if not file.exists():
        raise SystemExit(f"Required gradle file missing: {file}")
    text = file.read_text()
    if "repositories {" not in text:
        print("No repositories block found, skipping:", file)
        continue
    text = text.replace("repositories {", "repositories {" + mirror_lines, 1)
    file.write_text(text)
    print("Added mirror repositories:", file)
