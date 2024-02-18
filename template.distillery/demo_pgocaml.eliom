[%%shared
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)
(* PGOcaml demo *)
open Eliom_content.Html.F]

(* Service for this demo *)
let%server service =
  Eliom_service.create ~path:(Eliom_service.Path ["demo-pgocaml"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.pgocaml]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-pgocaml"

(* Fetch users in database *)
let%rpc get_users () : string list Lwt.t =
  (* For this demo, we add a delay to simulate a network or db latency: *)
  let%lwt () = Lwt_unix.sleep 2. in
  Demo_pgocaml_db.get ()

(* Generate page for this demo *)
let%shared page () =
  let%lwt user_block =
    Ot_spinner.with_spinner
      (let%lwt users = get_users () in
       let users =
         List.map
           (fun u -> if u = "" then li [em [txt "new user"]] else li [txt u])
           users
       in
       if users = []
       then Lwt.return [p [em [%i18n Demo.no_user_create_accounts]]]
       else Lwt.return [p [%i18n Demo.pgocaml_users]; ul users])
  in
  Lwt.return
    [ h1 [%i18n Demo.pgocaml]
    ; p [%i18n Demo.pgocaml_description_1]
    ; p [%i18n Demo.pgocaml_description_2]
    ; p [%i18n Demo.pgocaml_description_3]
    ; user_block ]
