open Ctypes

module C = Bindings.C(Generated)
module S = Structs.C(Structs_generated)

open S

exception Error of (string * int)
exception Enoent of (string * string option) (* function * filename *)

let () =
  Printexc.register_printer begin function
  | Error (func,error) -> Some (Printf.sprintf "Ceph.Error(%s,%d)" func error)
  | Enoent (func,None) -> Some (Printf.sprintf "Ceph.Enoent(%s)" func)
  | Enoent (func,Some fname) -> Some (Printf.sprintf "Ceph.Enoent(%s,%S)" func fname)
  | _ -> None
end

let check ?path func ret =
  match ret with
  | n when n < 0 -> if  n = -enoent then raise (Enoent (func,path)) else raise (Error (func,n))
  | _ -> ()

let check1 func f = fun a1 -> check func (f a1)
let check2 func f = fun a1 a2 -> check func (f a1 a2)
let check3 func f = fun a1 path a3 -> check ~path func (f a1 path a3)

type t = C.mount_info Ctypes.structure Ctypes_static.ptr
type fd = int

let version () =
  let major = allocate int 0 in
  let minor = allocate int 0 in
  let patch = allocate int 0 in
  let s = C.version major minor patch in
  s, (!@major, !@minor, !@patch )

let version_headers = (libcephfs_VER_MAJOR,libcephfs_VER_MINOR,libcephfs_VER_EXTRA)

let version_string () = fst @@ version ()
let version_number () = snd @@ version ()

let create ?id () =
  let mi = allocate C.handle (from_voidp C.struct_mount_info null) in
  check "create" @@ C.create mi id;
  !@mi

let release = check1 "release" C.release
let init = check1 "init" C.init
let mount ?root mi = check "mount" @@ C.mount mi root
let unmount = check1 "unmount" C.unmount
let conf_read_file ?path mi = check ?path "conf_read_file" @@ C.conf_read_file mi path
let conf_parse_env ?var mi = check "conf_parse_env" @@ C.conf_parse_env mi var
let chdir mi path = check ~path "chdir" @@ C.chdir mi path
let mkdir = check3 "mkdir" C.mkdir
let mkdirs = check3 "mkdirs" C.mkdirs
let rmdir mi path = check ~path "rmdir" @@ C.rmdir mi path
let getcwd = C.getcwd
let conf_set = check3 "conf_set" C.conf_set
let link mi ~target ~from = check ~path:target "link" @@ C.link mi target from
let symlink mi ~target ~from = check "symlink" @@ C.symlink mi target from
let unlink mi path = check ~path "unlink" @@ C.unlink mi path
let rename mi ~from ~target = check ~path:from "rename" @@ C.rename mi from target
let chmod = check3 "chmod" C.chmod
let chown mi path ~uid ~gid = check ~path "chown" @@ C.chown mi path uid gid
let lchown mi path ~uid ~gid = check ~path "lchown" @@ C.lchown mi path uid gid
let opendir mi path =
  let dir = allocate C.dir_result (from_voidp C.struct_dir_result null) in
  check ~path "opendir" @@ C.opendir mi path dir;
  !@dir
let closedir = check2 "closedir" C.closedir

type file_type =
  | BLK  (** This is a block device. *)
  | CHR  (** This is a character device. *)
  | DIR  (** This is a directory. *)
  | FIFO (** This is a named pipe (FIFO). *)
  | LNK  (** This is a symbolic link. *)
  | REG  (** This is a regular file. *)
  | SOCK (** This is a UNIX domain socket. *)
  | UNKNOWN (** The file type could not be determined. *)

type dirent = { inode : int64; typ : file_type; name : string; }

module Dirent = struct

let typ d =
  let c = getf !@d d_type in
  if c = dt_REG then REG
  else if c = dt_DIR then DIR
  else if c = dt_LNK then LNK
  else if c = dt_FIFO then FIFO
  else if c = dt_SOCK then SOCK
  else if c = dt_CHR then CHR
  else if c = dt_BLK then BLK
  else if c = dt_UNKNOWN then UNKNOWN
  else UNKNOWN

let inode d = getf !@d d_inode
let name d = coerce (ptr char) string (d |-> d_name)

let make d = { inode = inode d; typ = typ d; name = name d }

end

let readdir mi dir =
  match C.readdir mi dir with
  | None -> None
  | Some d -> Some (Dirent.make d)

type open_flag = O_RDONLY | O_WRONLY | O_RDWR |O_CREAT | O_EXCL | O_TRUNC | O_DIRECTORY | O_NOFOLLOW

let int_of_open_flag = function
| O_RDONLY -> o_RDONLY
| O_WRONLY -> o_WRONLY
| O_RDWR -> o_RDWR
| O_CREAT -> o_CREAT
| O_EXCL -> o_EXCL
| O_TRUNC -> o_TRUNC
| O_DIRECTORY -> o_DIRECTORY
| O_NOFOLLOW -> o_NOFOLLOW

let int_of_open_flags = List.fold_left (fun acc x -> acc lor int_of_open_flag x) 0

let openfile mi path flags mode =
  let fd = C.openfile mi path (int_of_open_flags flags) mode in
  check ~path "open" fd;
  fd

let close = check2 "close" C.close
let fallocate mi fd ofs len = check "fallocate" @@ C.fallocate mi fd 0 ofs len
let fsync mi fd ~dataonly = check "fsync" @@ C.fsync mi fd (if dataonly then 1 else 0)

type statx = {
  stx_type : file_type;
  stx_size : int64;
  stx_mtime : int;
  stx_btime : int;
}

module Statx = struct

let mode st = getf !@st stx_mode
let size st = getf !@st stx_size
let mtime st = getf (getf !@st stx_mtime) tv_sec
let btime st = getf (getf !@st stx_btime) tv_sec

let get_file_type mode =
  let open Unsigned.UInt16 in
  let t = logand mode s_IFMT in
  if t = s_IFREG then REG
  else if t = s_IFDIR then DIR
  else if t = s_IFLNK then LNK
  else if t = s_IFIFO then FIFO
  else if t = s_IFSOCK then SOCK
  else if t = s_IFCHR then CHR
  else if t = s_IFBLK then BLK
  else UNKNOWN

let want = Unsigned.UInt.(statx_MODE |> logor statx_SIZE |> logor statx_MTIME |> logor statx_BTIME)

let make st = {
  stx_type = get_file_type @@ mode st;
  stx_size = Unsigned.UInt64.to_int64 @@ size st;
  stx_mtime = PosixTypes.Time.to_int @@ mtime st;
  stx_btime = PosixTypes.Time.to_int @@ btime st;
}

end

let statx mi path =
  let st = allocate_n struct_statx ~count:1 in
  check ~path "statx" @@ C.statx mi path st Statx.want Unsigned.UInt.zero;
  Statx.make st

let fstatx mi fd =
  let st = allocate_n struct_statx ~count:1 in
  check "fstatx" @@ C.fstatx mi fd st Statx.want Unsigned.UInt.zero;
  Statx.make st

let readdirplus mi dir =
  (* TODO allocate once per mount because result immediately copied *)
  let st = allocate_n struct_statx ~count:1 in
  let d = allocate_n struct_dirent ~count:1 in
  let r = C.readdirplus mi dir d st Statx.want Unsigned.UInt.zero null in
  check "readdirplus" r;
  if r = 0 then None else Some (Dirent.make d, Statx.make st)
