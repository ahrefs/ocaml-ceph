open Ctypes

module C = Stubs.Bindings(Generated)

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
