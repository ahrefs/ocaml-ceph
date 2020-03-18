
module C(T : Cstubs_structs.TYPE) = struct

  open T

  let dt_BLK  = constant "DT_BLK" char (* This is a block device. *)
  let dt_CHR  = constant "DT_CHR" char (* This is a character device. *)
  let dt_DIR  = constant "DT_DIR" char (* This is a directory. *)
  let dt_FIFO = constant "DT_FIFO" char (* This is a named pipe (FIFO). *)
  let dt_LNK  = constant "DT_LNK" char (* This is a symbolic link. *)
  let dt_REG  = constant "DT_REG" char (* This is a regular file. *)
  let dt_SOCK = constant "DT_SOCK" char (* This is a UNIX domain socket. *)
  let dt_UNKNOWN = constant "DT_UNKNOWN" char (* The file type could not be determined. *)

end
