open Ctypes

module Bindings
  (F : Cstubs.FOREIGN) =
struct
  open F

  let version = foreign "ceph_version" @@ ptr int @-> ptr int @-> ptr int @-> returning string

  type struct_mount_info = [`Mount_info] structure
  let struct_mount_info : struct_mount_info typ = structure "ceph_mount_info"
  let handle = ptr struct_mount_info

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

end
