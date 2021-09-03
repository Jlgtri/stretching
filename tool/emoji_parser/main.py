"""
Get the .png icons for emoji in `emojipedia.org`.

Parses emoji name and saves to local storage.
"""

from asyncio import run
from os.path import isfile
from pathlib import Path

from aiofiles import open
from aiohttp import ClientSession
from bs4 import BeautifulSoup

# The path where data will be saved.
save_dir: Path = Path('emoji').absolute().resolve()


async def main() -> None:
    """Get the .png icons for emoji in `emojipedia.org`."""
    async with ClientSession() as session:
        async with session.get('https://emojipedia.org/apple/') as site:
            bs = BeautifulSoup(await site.text(), 'html.parser')
            grid = bs.find('ul', {'class': 'emoji-grid'})
            for child in grid.children:
                if isinstance(child, str):
                    continue
                img = child.find('img')
                src = str(
                    img['data-src']
                    if img['src'] == '/static/img/lazy.svg'
                    else img['src']
                )
                file_name = src.rsplit('/', 1)[-1]
                if isfile(save_dir / file_name):
                    continue
                async with session.get(src) as icon:
                    if not (save_dir.exists() and save_dir.is_dir()):
                        save_dir.mkdir(parents=True, exist_ok=True)
                    async with open(save_dir / file_name, mode='wb') as file:
                        await file.write(await icon.read())
                print(f'Got {file_name}...')


if __name__ == '__main__':
    run(main())
