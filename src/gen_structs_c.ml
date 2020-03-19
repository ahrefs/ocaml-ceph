let c_headers = [
  "cephfs/libcephfs.h";
  "dirent.h";
]

let () =
  c_headers |> List.iter (Format.printf "#include <%s>\n");
  Cstubs_structs.write_c Format.std_formatter (module Structs.C);
  Format.print_flush ()
