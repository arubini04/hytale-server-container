import logging
import os
import subprocess
import sys
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

HYTALE_DOWNLOADER_PATH = Path("/usr/local/bin/hytale-downloader")
HYTALE_HOME = Path(os.environ["HYTALE_HOME"])

HYTALE_SERVER_JAR_PATH = HYTALE_HOME / "Server" / "HytaleServer.jar"
HYTALE_ASSETS_ZIP_PATH = HYTALE_HOME / "Assets.zip"


def main():
    if not HYTALE_SERVER_JAR_PATH.exists():
        logging.warning("`HytaleServer.jar` not found. Downloading...")

        try:
            latest_zip_path = HYTALE_HOME / "latest.zip"

            subprocess.run(
                [str(HYTALE_DOWNLOADER_PATH), "-download-path", str(latest_zip_path)]
            )
            subprocess.run(
                ["unzip", str(latest_zip_path), "-d", str(HYTALE_HOME)],
                check=True,
            )

            if latest_zip_path.exists():
                latest_zip_path.unlink()
        except subprocess.CalledProcessError as e:
            logging.error(f"Something went wrong: {e}")
            sys.exit(1)

    java_args = [
        "java",
        "-Xms4G",
        "-Xmx10G",
        "-jar",
        str(HYTALE_SERVER_JAR_PATH),
        "--assets",
        str(HYTALE_ASSETS_ZIP_PATH),
    ]

    sys.stdout.flush()
    os.execvp("java", java_args)


if __name__ == "__main__":
    main()
