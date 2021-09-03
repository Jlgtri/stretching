"""Rename the icons to leave just the name or the unicode code."""

from os import listdir
from os.path import splitext
from pathlib import Path
from shutil import copyfile
from typing import Sequence

# The path where data will be saved.
import_dir: Path = Path('emoji').absolute().resolve()

# The path where data will be saved.
save_dir: Path = Path('emoji_unicode').absolute().resolve()

# 0 - only name, 1 - only unicode
mode: int = 1


def main():
    """Rename the icons to leave just the name or the unicode code."""
    if not save_dir.exists() or not save_dir.is_dir():
        save_dir.mkdir(parents=True, exist_ok=True)
    for file in listdir(import_dir):
        parts = splitext(file)
        name_parts: Sequence[str] = parts[0].split('_')
        name_parts = (
            ((name_parts[-2],) if mode else name_parts[:2])
            if len(name_parts) == 4
            else (name_parts[-mode],)
        )
        file_name = ''.join((*name_parts, *parts[1:]))
        copyfile(import_dir / file, save_dir / file_name)


if __name__ == '__main__':
    main()
