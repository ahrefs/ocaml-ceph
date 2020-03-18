open Ctypes

module C = Bindings.C(Generated)
module S = Structs.C(Structs_generated)

exception Error of (string * int)

let () =
  Printexc.register_printer (function Error (func,error) -> Some (Printf.sprintf "Ceph.Error(%S,%d)" func error) | _ -> None)

let check func ret =
  match ret with
  | 0 -> ()
  | n -> raise (Error (func,n))

let check1 func f = fun a1 -> check func (f a1)
let check2 func f = fun a1 a2 -> check func (f a1 a2)
let check3 func f = fun a1 a2 a3 -> check func (f a1 a2 a3)

type t = C.mount_info Ctypes.structure Ctypes_static.ptr
type fd = int

let version () =
  let major = allocate int 0 in
  let minor = allocate int 0 in
  let patch = allocate int 0 in
  let s = C.version major minor patch in
  s, (!@major, !@minor, !@patch )

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
let conf_read_file ?path mi = check "conf_read_file" @@ C.conf_read_file mi path
let conf_parse_env ?var mi = check "conf_parse_env" @@ C.conf_parse_env mi var
let chdir = check2 "chdir" C.chdir
let mkdir = check3 "mkdir" C.mkdir
let mkdirs = check3 "mkdirs" C.mkdirs
let rmdir = check2 "rmdir" C.rmdir
let getcwd = C.getcwd
let conf_set = check3 "conf_set" C.conf_set
let link mi ~target ~from = check "link" @@ C.link mi target from
let symlink mi ~target ~from = check "symlink" @@ C.symlink mi target from
let unlink = check2 "unlink" C.unlink
let rename mi ~from ~target = check "rename" @@ C.rename mi from target
let chmod = check3 "chmod" C.chmod
let chown mi path ~uid ~gid = check "chown" @@ C.chown mi path uid gid
let lchown mi path ~uid ~gid = check "lchown" @@ C.lchown mi path uid gid
let opendir mi path =
  let dir = allocate C.dir_result (from_voidp C.struct_dir_result null) in
  check "opendir" @@ C.opendir mi path dir;
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

module Dirent = struct

let typ d =
  let open S in
  let c = getf !@d C.d_type in
  if c = dt_BLK then BLK
  else if c = dt_REG then REG
  else if c = dt_DIR then DIR
  else if c = dt_CHR then CHR
  else if c = dt_FIFO then FIFO
  else if c = dt_LNK then LNK
  else if c = dt_SOCK then SOCK
  else if c = dt_UNKNOWN then UNKNOWN
  else UNKNOWN

let inode d = getf !@d C.d_inode
let name d = coerce (ptr char) string (d |-> C.d_name)

end

type dirent = { inode : int64; typ : file_type; name : string; }

let readdir mi dir =
  match C.readdir mi dir with
  | None -> None
  | Some d -> Some Dirent.{ inode = inode d; typ = typ d; name = name d }

type open_flag = O_RDONLY | O_WRONLY | O_RDWR |O_CREAT | O_EXCL | O_TRUNC | O_DIRECTORY | O_NOFOLLOW

let int_of_open_flag = let open S in function
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
  if fd < 0 then raise (Error ("open",fd));
  fd

let close = check2 "close" C.close
let fallocate mi fd ofs len = check "fallocate" @@ C.fallocate mi fd 0 ofs len


