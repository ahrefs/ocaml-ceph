let c_headers = "#include <cephfs/libcephfs.h>\n#include <dirent.h>"

let () =
  match Sys.argv with
  | [| _; "bindings"; "c" |] ->
    Format.printf "%s@\n" c_headers;
    Cstubs.write_c Format.std_formatter ~prefix:"ceph_stub_" (module Bindings.C);
    Format.print_flush ()
  | [| _; "bindings";"ml" |] ->
    Cstubs.write_ml Format.std_formatter ~prefix:"ceph_stub_" (module Bindings.C);
    Format.print_flush ()
  | [| _; "structs"; "c" |] ->
    Format.printf "%s@\n" c_headers;
    Cstubs_structs.write_c Format.std_formatter (module Structs.C);
    Format.print_flush ()
  | _ ->
    failwith "bad args"
