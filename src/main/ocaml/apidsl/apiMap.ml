open ApiAst


type 'a t = {
  map_uname : 'a t -> 'a -> uname -> uname;
  map_lname : 'a t -> 'a -> lname -> lname;
  map_macro : 'a t -> 'a -> macro -> macro;
  map_comment_fragment : 'a t -> 'a -> comment_fragment -> comment_fragment;
  map_comment : 'a t -> 'a -> comment -> comment;
  map_size_spec : 'a t -> 'a -> size_spec -> size_spec;
  map_type_name : 'a t -> 'a -> type_name -> type_name;
  map_enumerator : 'a t -> 'a -> enumerator -> enumerator;
  map_error_list : 'a t -> 'a -> error_list -> error_list;
  map_parameter : 'a t -> 'a -> parameter -> parameter;
  map_function_name : 'a t -> 'a -> function_name -> function_name;
  map_expr : 'a t -> 'a -> expr -> expr;
  map_decl : 'a t -> 'a -> decl -> decl;
}


let visit_list f v state l =
  List.map (f v state) l


let visit_uname v state = function
  | UName name -> UName name

let visit_lname v state = function
  | LName name -> LName name

let visit_macro v state = function
  | Macro macro -> Macro macro


let visit_comment_fragment v state = function
  | Cmtf_Doc doc ->
      Cmtf_Doc doc
  | Cmtf_UName uname ->
      let uname = v.map_uname v state uname in
      Cmtf_UName uname
  | Cmtf_LName lname ->
      let lname = v.map_lname v state lname in
      Cmtf_LName lname
  | Cmtf_Break ->
      Cmtf_Break


let visit_comment v state = function
  | Cmt_None ->
      Cmt_None
  | Cmt_Doc frags ->
      let frags = visit_list v.map_comment_fragment v state frags in
      Cmt_Doc frags
  | Cmt_Section frags ->
      let frags = visit_list v.map_comment_fragment v state frags in
      Cmt_Section frags


let visit_size_spec v state = function
  | Ss_UName uname ->
      let uname = v.map_uname v state uname in
      Ss_UName uname
  | Ss_LName lname ->
      let lname = v.map_lname v state lname in
      Ss_LName lname
  | Ss_Size ->
      Ss_Size
  | Ss_Bounded (size_spec, uname) ->
      let size_spec = v.map_size_spec v state size_spec in
      let uname = v.map_uname v state uname in
      Ss_Bounded (size_spec, uname)


let visit_type_name v state = function
  | Ty_UName uname ->
      let uname = v.map_uname v state uname in
      Ty_UName uname
  | Ty_LName lname ->
      let lname = v.map_lname v state lname in
      Ty_LName lname
  | Ty_Array (lname, size_spec) ->
      let lname = v.map_lname v state lname in
      let size_spec = v.map_size_spec v state size_spec in
      Ty_Array (lname, size_spec)
  | Ty_This ->
      Ty_This
  | Ty_Const type_name ->
      let type_name = v.map_type_name v state type_name in
      Ty_Const type_name


let visit_enumerator v state = function
  | Enum_Name (comment, uname) ->
      let comment = v.map_comment v state comment in
      let uname = v.map_uname v state uname in
      Enum_Name (comment, uname)
  | Enum_Namespace (uname, enumerators) ->
      let uname = v.map_uname v state uname in
      let enumerators = visit_list v.map_enumerator v state enumerators in
      Enum_Namespace (uname, enumerators)


let visit_error_list v state = function
  | Err_None ->
      Err_None
  | Err_From lname ->
      let lname = v.map_lname v state lname in
      Err_From lname
  | Err_List enumerators ->
      let enumerators = visit_list v.map_enumerator v state enumerators in
      Err_List enumerators


let visit_parameter v state = function
  | Param (type_name, lname) ->
      let type_name = v.map_type_name v state type_name in
      let lname = v.map_lname v state lname in
      Param (type_name, lname)


let visit_function_name v state = function
  | Fn_Custom (type_name, lname) ->
      let type_name = v.map_type_name v state type_name in
      let lname = v.map_lname v state lname in
      Fn_Custom (type_name, lname)
  | Fn_Size -> Fn_Size
  | Fn_Get -> Fn_Get
  | Fn_Set -> Fn_Set


let visit_expr v state = function
  | E_Number num ->
      E_Number num
  | E_UName uname ->
      let uname = v.map_uname v state uname in
      E_UName uname
  | E_Sizeof lname ->
      let lname = v.map_lname v state lname in
      E_Sizeof lname
  | E_Plus (lhs, rhs) ->
      let lhs = v.map_expr v state lhs in
      let rhs = v.map_expr v state rhs in
      E_Plus (lhs, rhs)


let visit_decl v state = function
  | Decl_Comment (comment, decl) ->
      let comment = v.map_comment v state comment in
      let decl = v.map_decl v state decl in
      Decl_Comment (comment, decl)
  | Decl_Static decl ->
      let decl = v.map_decl v state decl in
      Decl_Static decl
  | Decl_Macro macro ->
      let macro = v.map_macro v state macro in
      Decl_Macro macro
  | Decl_Namespace (lname, decls) ->
      let lname = v.map_lname v state lname in
      let decls = visit_list v.map_decl v state decls in
      Decl_Namespace (lname, decls)
  | Decl_Class (lname, decls) ->
      let lname = v.map_lname v state lname in
      let decls = visit_list v.map_decl v state decls in
      Decl_Class (lname, decls)
  | Decl_Function (function_name, parameters, error_list) ->
      let function_name = v.map_function_name v state function_name in
      let parameters = visit_list v.map_parameter v state parameters in
      let error_list = v.map_error_list v state error_list in
      Decl_Function (function_name, parameters, error_list)
  | Decl_Const (uname, expr) ->
      let uname = v.map_uname v state uname in
      let expr = v.map_expr v state expr in
      Decl_Const (uname, expr)
  | Decl_Enum (is_class, uname, enumerators) ->
      let uname = v.map_uname v state uname in
      let enumerators = visit_list v.map_enumerator v state enumerators in
      Decl_Enum (is_class, uname, enumerators)
  | Decl_Error (lname, enumerators) ->
      let lname = v.map_lname v state lname in
      let enumerators = visit_list v.map_enumerator v state enumerators in
      Decl_Error (lname, enumerators)
  | Decl_Struct decls ->
      let decls = visit_list v.map_decl v state decls in
      Decl_Struct decls
  | Decl_Member (type_name, lname) ->
      let type_name = v.map_type_name v state type_name in
      let lname = v.map_lname v state lname in
      Decl_Member (type_name, lname)
  | Decl_GetSet (type_name, lname, decls) ->
      let type_name = v.map_type_name v state type_name in
      let lname = v.map_lname v state lname in
      let decls = visit_list v.map_decl v state decls in
      Decl_GetSet (type_name, lname, decls)
  | Decl_Typedef (lname, parameters) ->
      let lname = v.map_lname v state lname in
      let parameters = visit_list v.map_parameter v state parameters in
      Decl_Typedef (lname, parameters)
  | Decl_Event (lname, decl) ->
      let lname = v.map_lname v state lname in
      let decl = v.map_decl v state decl in
      Decl_Event (lname, decl)


let visit_decls v state = visit_list v.map_decl v state


let default = {
  map_uname = visit_uname;
  map_lname = visit_lname;
  map_macro = visit_macro;
  map_comment_fragment = visit_comment_fragment;
  map_comment = visit_comment;
  map_size_spec = visit_size_spec;
  map_type_name = visit_type_name;
  map_enumerator = visit_enumerator;
  map_error_list = visit_error_list;
  map_parameter = visit_parameter;
  map_function_name = visit_function_name;
  map_expr = visit_expr;
  map_decl = visit_decl;
}