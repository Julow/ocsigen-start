[%%shared
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)
(* Page with several tabs *)
open Eliom_content.Html]

[%%shared open Eliom_content.Html.F]

let%shared lorem_ipsum =
  [ p
      [ txt
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Hanc ergo intuens debet institutum illud quasi signum absolvere. Animi enim quoque dolores percipiet omnibus partibus maiores quam corporis. Atque haec ita iustitiae propria sunt, ut sint virtutum reliquarum communia. Sed ad bona praeterita redeamus. Duarum enim vitarum nobis erunt instituta capienda. Nunc ita separantur, ut disiuncta sint, quo nihil potest esse perversius. Hoc est non dividere, sed frangere. Duo Reges: constructio interrete. Satis est ad hoc responsum."
      ]
  ; p
      [ txt
          "Traditur, inquit, ab Epicuro ratio neglegendi doloris. Quod quidem iam fit etiam in Academia. Quodcumque in mentem incideret, et quodcumque tamquam occurreret. Immo vero, inquit, ad beatissime vivendum parum est, ad beate vero satis. Re mihi non aeque satisfacit, et quidem locis pluribus."
      ]
  ; p
      [ txt
          "Amicitiam autem adhibendam esse censent, quia sit ex eo genere, quae prosunt. Hoc loco tenere se Triarius non potuit. Facile est hoc cernere in primis puerorum aetatulis. Sed in rebus apertissimis nimium longi sumus. Utrum igitur tibi litteram videor an totas paginas commovere? Quid de Platone aut de Democrito loquar?"
      ] ]

(* Service for this demo *)
let%server service =
  Eliom_service.create ~path:(Eliom_service.Path ["demo-carousel2"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.carousel_2]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-carousel2"

(* Page for this demo *)
let%shared page () =
  let make_page name =
    let c = if name = "1" then lorem_ipsum else [] in
    div
      ~a:[a_class ["demo-carousel2-page"; "demo-carousel2-page-" ^ name]]
      (p [txt "Page "; txt name] :: c)
  in
  let make_tab name = [txt "Page "; txt name] in
  let carousel_change_signal =
    [%client
      (React.E.create ()
       : ([`Goto of int | `Next | `Prev] as 'a) React.E.t
         * (?step:React.step -> 'a -> unit))]
  in
  let update = [%client fst ~%carousel_change_signal] in
  let change = [%client fun a -> snd ~%carousel_change_signal ?step:None a] in
  let carousel_pages = ["1"; "2"; "3"; "4"] in
  let carousel_content = List.map make_page carousel_pages in
  let tab_content = List.map make_tab carousel_pages in
  let tabs_r = ref (div []) in
  let get_header_height =
    [%client
      fun () ->
        let t = To_dom.of_element !(~%tabs_r) in
        int_of_float (Ot_size.client_top t) + t##.offsetHeight]
  in
  (* We want a "full-height" carousel. See Ot_carousel documentation. *)
  let {Ot_carousel.elt = carousel; pos; swipe_pos} =
    Ot_carousel.make ~update ~full_height:(`Header get_header_height)
      carousel_content
  in
  let ribbon = Ot_carousel.ribbon ~change ~pos ~cursor:swipe_pos tab_content in
  let tabs =
    (* ribbon container is necessary for shadow,
       because position:sticky is not interpreted as relative
       on browsers that do not support sticky. *)
    D.div ~a:[a_class ["demo-carousel2-tabs"]] [ribbon]
  in
  tabs_r := ribbon;
  (* We want the tabs to be always visible on top of the page.
     To do that, we use position: sticky;
     As this is not available in all browsers, we use a polyfill to
     simulate this behaviour when not supported:
  *)
  ignore
    [%client
      (Lwt.async (fun () ->
         Lwt.map ignore
           (Ot_sticky.make_sticky ~ios_html_scroll_hack:true ~dir:`Top ~%tabs))
       : unit)];
  Lwt.return
    [ h1 [%i18n Demo.carousel_2]
    ; p [%i18n Demo.ot_carousel_second_example_1]
    ; p [%i18n Demo.ot_carousel_second_example_2]
    ; p [%i18n Demo.ot_carousel_second_example_3]
    ; div
        ~a:[a_class ["demo-carousel2"]]
        [div ~a:[a_class ["demo-carousel2-box"]] [tabs; carousel]] ]
