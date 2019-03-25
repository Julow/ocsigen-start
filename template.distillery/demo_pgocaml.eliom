(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(* PGOcaml demo *)

[%%shared
  open Eliom_content.Html.F
]

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-pgocaml"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n S.demo_pgocaml]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-pgocaml"

(* Fetch users in database *)
let%server get_users () =
  (* For this demo, we add a delay to simulate a network or db latency: *)
  let%lwt () = Lwt_unix.sleep 2. in
  Demo_pgocaml_db.get ()

(* Make function get_users available to the client *)
let%client get_users =
  ~%(Eliom_client.server_function [%derive.json: unit]
       (Os_session.connected_wrapper get_users))

(* Generate page for this demo *)
let%shared page () =
  let%lwt user_block =
    Ot_spinner.with_spinner
      (let%lwt users = get_users () in
       let users = List.map (fun u -> if u = ""
                              then li [em [txt "new user"]]
                              else li [txt u]) users
       in
       if users = []
       then Lwt.return
           [ p [ em [%i18n no_user_create_accounts]]]
       else Lwt.return [ p [%i18n demo_pgocaml_users]
                       ; ul users ])
  in
  Lwt.return [ h1 [%i18n demo_pgocaml]
             ; p [%i18n demo_pgocaml_description_1]
             ; p [%i18n demo_pgocaml_description_2]
             ; p [%i18n demo_pgocaml_description_3]
             ; user_block ]
