
open Ace_utils
open Indent


let make_editor (container: Dom_html.element Js.t) : unit =
  let doc = Dom_html.document in
  let div_input = Dom_html.createDiv doc in
  let div_tabs = Dom_html.createDiv doc in
  let div_listtabs = Dom_html.createDiv doc in
  let div_editor = Dom_html.createDiv doc in
  let script_ace_init = Dom_html.createScript doc in
  let css_tabs = Dom_html.createLink doc in

  div_input##id <- Js.string "input";
  div_tabs##id <- Js.string "tabs";
  div_listtabs##id <- Js.string "listtabs";
  div_editor##id <- Js.string "editor";
  script_ace_init##text <- Js.string
    "var editor = ace.edit(\"editor\");
     editor.setTheme(\"ace/theme/eclipse\");
     editor.getSession().setMode(\"ace/mode/ocaml_ocp\");";
  container##style##zIndex <- Js.string "5";
  container##style##minWidth <- Js.string "620px";
  css_tabs##href <- Js.string "./tabs.css";
  css_tabs##rel <- Js.string "stylesheet";
  css_tabs##_type <- Js.string "text/css";

  Dom.appendChild container div_input;
  Dom.appendChild container div_tabs;
  Dom.appendChild container div_listtabs;
  Dom.appendChild container div_editor;
  Dom.appendChild doc##body script_ace_init;
  Dom.appendChild doc##body css_tabs;

  Tabs.main ()

  

let _ =
  (Js.Unsafe.coerce Dom_html.window)##makeEditor <- Js.wrap_callback
     make_editor
