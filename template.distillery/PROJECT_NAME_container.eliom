(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(** This module defines the default template for application pages *)


let%shared navigation_bar =
  let nav_elts = [
    ("Home",Eba_services.main_service);
    ("About",%%%MODULE_NAME%%%_services.about_service);
    ("Demo",%%%MODULE_NAME%%%_services.otdemo_service)
  ] in
  fun () ->
    Eba_tools.Navigation_bar.ul_of_elts
      ~ul_class:["nav";"navbar-nav"]
      nav_elts

let%shared eba_header ?user () = Eliom_content.Html.F.(
  ignore user;
  let%lwt user_box = 
    %%%MODULE_NAME%%%_userbox.userbox user in
  let%lwt navigation_bar = navigation_bar () in
  Lwt.return (
    nav ~a:[a_class ["navbar";"navbar-inverse";"navbar-relative-top"]] [
      div ~a:[a_class ["container-fluid"]] [
	div ~a:[a_class ["navbar-header"]][
	  a ~a:[a_class ["navbar-brand"]]
            ~service:Eba_services.main_service [
	      pcdata %%%MODULE_NAME%%%_base.displayed_app_name;
	    ] ();
	  user_box
	];
	navigation_bar
      ]
    ]
  )
)

let%shared eba_footer () = Eliom_content.Html.F.(
  footer ~a:[a_class ["footer";"navbar";"navbar-inverse"]] [
    div ~a:[a_class ["container"]] [
      p [
	pcdata "This application has been generated using the ";
	a ~service:Eba_services.eba_github_service [
	  pcdata "Eliom-base-app"
	] ();
	pcdata " template for Eliom-distillery and uses the ";
	a ~service:Eba_services.ocsigen_service [
	  pcdata "Ocsigen"
	] ();
	pcdata " technology.";
      ]
    ]
  ]
)

let%server get_wrong_pdata () =
  Lwt.return @@ Eliom_reference.Volatile.get Eba_msg.wrong_pdata

let%client get_wrong_pdata =
  ~%(Eliom_client.server_function [%derive.json : unit] get_wrong_pdata)

let%shared connected_welcome_box () = Eliom_content.Html.F.(
  let%lwt wrong_pdata = get_wrong_pdata () in
  let info, ((fn, ln), (p1, p2)) =
    match wrong_pdata with
    | None ->
      p [
        pcdata "Your personal information has not been set yet.";
        br ();
        pcdata "Please take time to enter your name and to set a password."
      ], (("", ""), ("", ""))
    | Some wpd -> p [pcdata "Wrong data. Please fix."], wpd
  in
  Lwt.return @@
    div ~a:[a_class ["eba-login-menu";"eba-welcome-box"]] [
      div [h2 [pcdata ("Welcome!")]; info];
      Eba_view.information_form
	~firstname:fn ~lastname:ln
	~password1:p1 ~password2:p2
	()
    ]
)

let%shared get_user_data = function
  | None ->
    Lwt.return None
  | Some userid ->
    let%lwt u = Eba_user_proxy.get_data userid in
    Lwt.return (Some u)

let%shared page userid_o content = Eliom_content.Html.F.(
  let%lwt user = get_user_data userid_o in
  let%lwt content = match user with
    | Some user when not (Eba_user.is_complete user) ->
      let%lwt cwb = connected_welcome_box () in
      Lwt.return @@ cwb :: content
    | _ ->
      Lwt.return @@ content
  in
  let l = [
    div ~a:[a_class ["eba-body"]] content;
    eba_footer ();
  ] in
  let%lwt h = eba_header ?user () in
  Lwt.return @@ h :: l
)


