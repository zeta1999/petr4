open Core
open Petr4
open Petr4.Types

module TableVertex = struct
  type t = 
    { name : P4String.t;
      properties : Table.property list }
    let compare = Stdlib.compare
    let hash = Hashtbl.hash
    let equal = Stdlib.(=)
end

module TableGraph = Graph.Persistent.Digraph.Concrete(TableVertex)

(*
  Final questions before I can convert my notes to code:
  - What is the entry point for the P4 Program? I couldn't find where the Petr4 evaluator is initially called
    - i.e. what is "main" in a typical V1model program?
  - What is the direct application statement? Please point me to an example in a P4 program if possible

*)

let format_table_graph fmt g =
  failwith "todo"
(* not sure why name was an unbound field in the following
  let f = fun v1 v2 s -> s ^ "\n" ^ (snd v1.name) " can go to " ^ (snd v2.name) in
  let graph_string = TableGraph.fold_edges f g "" in
  Format.fprintf fmt (graph_string ^ "\n")
*)


(*
  get declarations, store in graph
   - need way to access existing nodes by table name (not by table data itself)
   - if the graph library doesn't make this easy, will use an additional map to get a table from its name
  add edges to table graph
  - need to figure out what node is the entry point for a P4 program, traverse that tree to add the edges
  - Don't know how to appropriately handle scope
     - two different tables with the same name in different scopes (possible in a correct program, I think)
     - application of a table not in current scope (not allowed, as far as I'm aware)

*)

(* Statements
    assignment can't contain table application (i'm fairly sure, though this isn't apparent from the types)
    block statement just recursively gets edges from its statements
    direct application? I haven't been able to figure out what it even is
    conditional/switch need to be checked
      - add edge for each branch with a table application
    methodcall is where table application occurs
      - func is a expressionmember with "apply" and tablename as parameters
    _ -> g , cannot contain other statement(s) or a table application
*)

let edges_from_stmt g prev stmt =
  let open Statement in
  match stmt with
    | _, MethodCall s -> g
    | _, DirectApplication da -> g
    | _, Conditional cnd -> g
    | _, Switch sw -> g
    | _, BlockStatement bl -> g
    | _ -> g

let edges_from_block g block =
  match block with
    | [] -> g
    | h::t -> (* if first application found then thread above helper through t with first application in prev
                     else call this again on t until empty *)
       failwith "todo"

(*
    need to know the entry point of the program to fix this:
    is "main" a declaration? which constructor? the only one that seems to make sense, based on types, is control
    can tables be declared anywhere other than inside a control? I don't think so (maybe technically the parser)
*)

let rec tables_declaration g decl =
  let open Declaration in
  match decl with
  | _, Control ctrl ->
     let g' = List.fold_left ctrl.locals ~init:g ~f:tables_declaration in
     edges_from_block g' (snd ctrl.apply).statements
  | _, Table tbl ->
     Format.eprintf "TABLE: %s@\n" (snd tbl.name);
     let t =
       TableVertex.{ name = tbl.name;
                     properties = tbl.properties } in
     TableGraph.add_vertex g t
  | _ -> g


let tables_program g prog = 
  let Program decls = prog in 
  List.fold_left decls ~f:tables_declaration ~init:g

let go verbose include_dirs p4file = 
  let () = Lexer.reset () in 
  let () = Lexer.set_filename p4file in 
  let p4string = 
    let buf = Buffer.create 101 in 
    let _ = P4pp.Eval.(preprocess_file include_dirs { file = p4file; defines = [] } buf p4file) in 
    Buffer.contents buf in
  let lexbuf = Lexing.from_string p4string in
  try
    let prog = Petr4.Parser.p4program Lexer.lexer lexbuf in 
    let tables = tables_program TableGraph.empty prog in 
    Format.printf "%a@\n" format_table_graph tables
  with
  | err -> 
     Format.eprintf "[%s] Failed@\n%!" p4file
  
let tables_command =
  let open Command.Spec in
  Command.basic_spec
    ~summary: "Compute table graph for P4_16 program"
    (empty
     +> flag "-v" no_arg ~doc:" Enable verbose output"
     +> flag "-I" (listed string) ~doc:"<dir> Add directory to include search path"
     +> anon ("p4file" %: string))
     (fun verbose include_dirs p4file () ->
       ignore (go verbose include_dirs p4file))

let () = Command.run ~version: "0.1.1" tables_command