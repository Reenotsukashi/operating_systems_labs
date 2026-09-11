import os
import errno
import stat
import logging
from fuse import Operations, FuseOSError

from converters import ConvertCache

log = logging.getLogger("fuse")


class ConvertFS(Operations):

    def __init__(self, original_dir):
        self.original_dir = os.path.abspath(original_dir)
        self.cache = ConvertCache()
        log.info("FS init, original_dir=%s", self.original_dir)


    def _real_path(self, path):
        return os.path.join(self.original_dir, path.lstrip("/"))

    def _is_virtual_jpg(self, path):
        if not path.endswith(".jpg"):
            return False
        png = self._real_path(path[:-4] + ".png")
        return os.path.isfile(png)

    def _source_png(self, path):
        return self._real_path(path[:-4] + ".png")

    def _virtual_size(self, path):
        return len(self.cache.get(self._source_png(path)))


    def getattr(self, path, fh=None):
        if self._is_virtual_jpg(path):
            png = self._source_png(path)
            st = os.lstat(png)
            size = self._virtual_size(path)
            return {
                "st_mode": stat.S_IFREG | 0o444,
                "st_nlink": 1,
                "st_size": size,
                "st_ctime": st.st_ctime,
                "st_mtime": st.st_mtime,
                "st_atime": st.st_atime,
                "st_uid": st.st_uid,
                "st_gid": st.st_gid,
            }
        real = self._real_path(path)
        try:
            st = os.lstat(real)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)
        return {
            "st_mode": st.st_mode,
            "st_nlink": st.st_nlink,
            "st_size": st.st_size,
            "st_ctime": st.st_ctime,
            "st_mtime": st.st_mtime,
            "st_atime": st.st_atime,
            "st_uid": st.st_uid,
            "st_gid": st.st_gid,
        }


    def readdir(self, path, fh):
        real = self._real_path(path)
        try:
            entries = os.listdir(real)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)

        result = [".", ".."]
        for name in entries:
            result.append(name)
            if name.endswith(".png"):
                jpg = name[:-4] + ".jpg"
                if jpg not in entries:
                    result.append(jpg)
        log.info("readdir %s -> %s", path, result)
        return result


    def open(self, path, flags):
        if self._is_virtual_jpg(path):
            if flags & (os.O_WRONLY | os.O_RDWR):
                raise FuseOSError(errno.EACCES)
            return 0 
        real = self._real_path(path)
        try:
            return os.open(real, flags)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)

    def read(self, path, size, offset, fh):
        if self._is_virtual_jpg(path):
            data = self.cache.get(self._source_png(path))
            return data[offset:offset + size]
        try:
            return os.pread(fh, size, offset)
        except OSError:
            raise FuseOSError(errno.EIO)

    def release(self, path, fh):
        if self._is_virtual_jpg(path):
            return 0
        try:
            os.close(fh)
        except OSError:
            pass
        return 0


    def create(self, path, mode, fi=None):
        real = self._real_path(path)
        fd = os.open(real, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, mode)
        log.info("create %s", path)
        return fd

    def write(self, path, data, offset, fh):
        return os.pwrite(fh, data, offset)

    def truncate(self, path, length, fh=None):
        real = self._real_path(path)
        try:
            os.truncate(real, length)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)
        return 0

    def unlink(self, path):
        if self._is_virtual_jpg(path):
            raise FuseOSError(errno.EACCES)
        real = self._real_path(path)
        try:
            os.unlink(real)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)
        self.cache.invalidate(real)
        log.info("unlink %s", path)
        return 0

    def mkdir(self, path, mode):
        real = self._real_path(path)
        os.mkdir(real, mode)
        log.info("mkdir %s", path)
        return 0

    def rmdir(self, path):
        real = self._real_path(path)
        try:
            os.rmdir(real)
        except FileNotFoundError:
            raise FuseOSError(errno.ENOENT)
        except OSError as e:
            raise FuseOSError(e.errno)
        log.info("rmdir %s", path)
        return 0

    def rename(self, old, new):
        real_old = self._real_path(old)
        real_new = self._real_path(new)
        os.rename(real_old, real_new)
        self.cache.invalidate(real_old)
        log.info("rename %s -> %s", old, new)
        return 0

    def chmod(self, path, mode):
        if self._is_virtual_jpg(path):
            raise FuseOSError(errno.EACCES)
        os.chmod(self._real_path(path), mode)
        return 0


    def chown(self, path, uid, gid):
        raise FuseOSError(errno.ENOTSUP)

    def link(self, target, source):
        raise FuseOSError(errno.ENOTSUP)

    def symlink(self, target, source):
        raise FuseOSError(errno.ENOTSUP)

    def readlink(self, path):
        raise FuseOSError(errno.ENOTSUP)