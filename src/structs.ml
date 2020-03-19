open Ctypes

module C(T : Cstubs_structs.TYPE) = struct

  open T

  let c s = constant s int
  let libcephfs_VER_MAJOR = c "LIBCEPHFS_VER_MAJOR"
  let libcephfs_VER_MINOR = c "LIBCEPHFS_VER_MINOR"
  let libcephfs_VER_EXTRA = c "LIBCEPHFS_VER_EXTRA"

  let enoent = constant "ENOENT" int

  let c s = constant s char
  let dt_BLK  = c "DT_BLK" (* This is a block device. *)
  let dt_CHR  = c "DT_CHR" (* This is a character device. *)
  let dt_DIR  = c "DT_DIR" (* This is a directory. *)
  let dt_FIFO = c "DT_FIFO" (* This is a named pipe (FIFO). *)
  let dt_LNK  = c "DT_LNK" (* This is a symbolic link. *)
  let dt_REG  = c "DT_REG" (* This is a regular file. *)
  let dt_SOCK = c "DT_SOCK" (* This is a UNIX domain socket. *)
  let dt_UNKNOWN = c "DT_UNKNOWN" (* The file type could not be determined. *)

  let c s = constant s int
  let o_RDONLY = c "O_RDONLY"
  let o_WRONLY = c "O_WRONLY"
  let o_RDWR = c "O_RDWR"
  let o_CREAT = c "O_CREAT"
  let o_EXCL = c "O_EXCL"
  let o_TRUNC = c "O_TRUNC"
  let o_DIRECTORY = c "O_DIRECTORY"
  let o_NOFOLLOW = c "O_NOFOLLOW"

  type dirent
  let struct_dirent : dirent structure typ = structure "dirent"
  let ( -: ) ty label = field struct_dirent label ty
  let d_inode  = int64_t -: "d_ino" (* could use PosixTypes.ino_t but libcephfs explicitly requires int64 *)
  let d_off    = int64_t -: "d_off"
  let d_reclen = short   -: "d_reclen"
  let d_type   = char    -: "d_type"
  let d_name   = char    -: "d_name" (* char d_name[] *)
  let () = seal struct_dirent

  let c s = constant s uint
  let statx_ALL_STATS = c "CEPH_STATX_ALL_STATS"
  let statx_BASIC_STATS = c "CEPH_STATX_BASIC_STATS"
  let statx_MODE = c "CEPH_STATX_MODE"
  let statx_SIZE = c "CEPH_STATX_SIZE"
  let statx_MTIME = c "CEPH_STATX_MTIME"
  let statx_BTIME = c "CEPH_STATX_BTIME"

  type timespec
  let struct_timespec : timespec structure typ = structure "timespec"
  let tv_sec = field struct_timespec "tv_sec" (lift_typ PosixTypes.time_t)
  let tv_nsec = field struct_timespec "tv_nsec" long
  let () = seal struct_timespec

  type statx
  let struct_statx : statx structure typ = structure "ceph_statx"
  let ( -: ) ty label = field struct_statx label ty
  let stx_mode  = uint16_t -: "stx_mode"
  let stx_size  = uint64_t -: "stx_size"
  let stx_mtime = struct_timespec -: "stx_mtime"
  let stx_btime = struct_timespec -: "stx_btime"
  let () = seal struct_statx

  (* inode(7) *)

  let c s = constant s uint16_t
  let s_IFMT = c "S_IFMT" (* bit mask for the file type bit field *)
  let s_IFSOCK = c "S_IFSOCK"
  let s_IFLNK = c "S_IFLNK"
  let s_IFREG = c "S_IFREG"
  let s_IFBLK = c "S_IFBLK"
  let s_IFDIR = c "S_IFDIR"
  let s_IFCHR = c "S_IFCHR"
  let s_IFIFO = c "S_IFIFO"

end
