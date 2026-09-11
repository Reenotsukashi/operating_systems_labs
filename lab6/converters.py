import os
import io
import logging
from PIL import Image

log = logging.getLogger("fuse")


class ConvertCache:

    def __init__(self):
        self._cache = {}

    def get(self, png_path):
        mtime = os.path.getmtime(png_path)
        entry = self._cache.get(png_path)
        if entry and entry[0] == mtime:
            log.info("cache hit: %s", png_path)
            return entry[1]
        data = self._convert(png_path)
        self._cache[png_path] = (mtime, data)
        log.info("cache miss, converted: %s (%d bytes)", png_path, len(data))
        return data

    def invalidate(self, png_path):
        self._cache.pop(png_path, None)

    @staticmethod
    def _convert(png_path):
        with Image.open(png_path) as img:
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=90)
            return buf.getvalue()