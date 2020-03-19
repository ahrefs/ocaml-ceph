open Ctypes

module S = Structs.C(Structs_generated)

module C(F : Cstubs.FOREIGN) =
struct
  open F

  let version = foreign "ceph_version" @@ ptr int @-> ptr int @-> ptr int @-> returning string

  type mount_info
  let struct_mount_info : mount_info structure typ = structure "ceph_mount_info"
  let handle = ptr struct_mount_info

  let fd = int

  type dir_result
  let struct_dir_result : dir_result structure typ = structure "ceph_dir_result"
  let dir_result = ptr struct_dir_result

  let create = foreign "ceph_create" @@ ptr handle @-> string_opt @-> returning int
  let release = foreign "ceph_release" @@ handle @-> returning int

  let init = foreign "ceph_init" @@ handle @-> returning int
  let mount = foreign "ceph_mount" @@ handle @-> string_opt @-> returning int
  let unmount = foreign "ceph_unmount" @@ handle @-> returning int

  let conf_read_file = foreign "ceph_conf_read_file" @@ handle @-> string_opt @-> returning int
  let conf_parse_env = foreign "ceph_conf_parse_env" @@ handle @-> string_opt @-> returning int
  let conf_set = foreign "ceph_conf_set" @@ handle @-> string @-> string @-> returning int

  let getcwd = foreign "ceph_getcwd" @@ handle @-> returning string
  let chdir = foreign "ceph_chdir" @@ handle @-> string @-> returning int
  let mkdir = foreign "ceph_mkdir" @@ handle @-> string @-> int @-> returning int
  let mkdirs = foreign "ceph_mkdirs" @@ handle @-> string @-> int @-> returning int
  let rmdir = foreign "ceph_rmdir" @@ handle @-> string @-> returning int

  let link = foreign "ceph_link" @@ handle @-> string @-> string @-> returning int
  let symlink = foreign "ceph_symlink" @@ handle @-> string @-> string @-> returning int
  let unlink = foreign "ceph_unlink" @@ handle @-> string @-> returning int

  let rename = foreign "ceph_rename" @@ handle @-> string @-> string @-> returning int
  let chmod = foreign "ceph_chmod" @@ handle @-> string @-> int @-> returning int
  let chown = foreign "ceph_chown" @@ handle @-> string @-> int @-> int @-> returning int
  let lchown = foreign "ceph_lchown" @@ handle @-> string @-> int @-> int @-> returning int

  let opendir = foreign "ceph_opendir" @@ handle @-> string @-> ptr dir_result @-> returning int
  let closedir = foreign "ceph_closedir" @@ handle @-> dir_result @-> returning int
  let readdir = foreign "ceph_readdir" @@ handle @-> dir_result @-> returning (ptr_opt S.struct_dirent)
  let readdirplus = foreign "ceph_readdirplus_r" @@
    handle @-> dir_result @-> ptr S.struct_dirent @-> ptr S.struct_statx @-> uint @-> uint @-> ptr void @-> returning int

  let openfile = foreign "ceph_open" @@ handle @-> string @-> int @-> int @-> returning fd
  let close = foreign "ceph_close" @@ handle @-> fd @-> returning int
  let fallocate = foreign "ceph_fallocate" @@ handle @-> fd @-> int @-> int64_t @-> int64_t @-> returning int
  let fsync = foreign "ceph_fsync" @@ handle @-> fd @-> int @-> returning int

  let statx = foreign "ceph_statx" @@ handle @-> string @-> ptr S.struct_statx @-> uint @-> uint @-> returning int
  let fstatx = foreign "ceph_fstatx" @@ handle @-> fd @-> ptr S.struct_statx @-> uint @-> uint @-> returning int

end
