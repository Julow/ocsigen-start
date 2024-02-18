[%%shared
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)
(* Os_current_user demo *)
open Eliom_content.Html.F]

(* Service for this demo *)
let%server service =
  Eliom_service.create ~path:(Eliom_service.Path ["demo-users"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.users]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-users"

let%shared display_user_name = function
  | None -> p [%i18n Demo.you_are_not_connected]
  | Some user ->
      p
        [ txt ([%i18n Demo.S.you_are] ^ " ")
        ; em [txt (Os_user.fullname_of_user user)] ]

let%shared display_user_id = function
  | None -> p [%i18n Demo.log_in_to_see_demo]
  | Some userid ->
      p
        [ txt ([%i18n Demo.S.your_user_id] ^ " ")
        ; em [txt (Int64.to_string userid)] ]

(* Page for this demo *)
let%shared page () =
  (* We use the convention to use "myid" for the user id of currently
     connected user, and "userid" for all other user id.
     We recommend to follow this convention, to reduce the risk
     of mistaking an user for another.
     We use prefix "_o" for optional value.
  *)
  let myid_o = Os_current_user.Opt.get_current_userid () in
  let me_o = Os_current_user.Opt.get_current_user () in
  Lwt.return
    [ h1 [%i18n Demo.users]
    ; p
        [ txt [%i18n Demo.S.the_module]
        ; code [txt " Os_current_user "]
        ; txt [%i18n Demo.S.allows_get_information_currently_connected_user] ]
    ; display_user_name me_o
    ; display_user_id myid_o
    ; p [txt [%i18n Demo.S.these_functions_called_server_or_client_side]]
    ; p
        [ txt [%i18n Demo.S.always_get_current_user_using_module]
        ; code [txt " Os_current_user. "]
        ; txt [%i18n Demo.S.never_trust_client_pending_user_id] ] ]
