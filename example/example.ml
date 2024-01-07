
open Ceph

let () =
  let mi = create () in
  conf_read_file mi;
  conf_parse_env mi;
  mount mi;
  print_endline @@ getcwd mi;
  chdir mi "clickhouse";
  print_endline @@ getcwd mi;
  chdir mi "";
  print_endline @@ getcwd mi;
  chdir mi "/";
  print_endline @@ getcwd mi;
  chdir mi "/clickhouse";
  print_endline @@ getcwd mi;
  let readdir_all mi dir =
    let rec loop acc =
      match readdirplus mi dir with
      | None -> acc
      | Some r -> loop (r::acc)
    in
    loop []
  in
  let l =
    let dir = opendir mi "/" in
    let l = readdir_all mi dir in
    closedir mi dir;
    l
  in
  l |> List.iter begin fun (d,st) ->
    Printf.printf "%c%c %Ld %d %15Ld %s\n"
      (match d.typ with REG -> ' ' | DIR -> 'd' | _ -> 'x')
      (match st.stx_type with REG -> ' ' | DIR -> 'd' | _ -> 'x')
      st.stx_size
      st.stx_mtime
      d.inode
      d.name
  end;
  unmount mi;
  release mi
