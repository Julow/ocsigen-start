(** abstract type which correspond to a group.
  * a user belongs to one or more groups, each
  * group grants him some special rights (e.g:
  * beta-user, admin or whatever. *)
{shared{
  type shared_t = { id : int64; name : string; desc : string option } deriving (Json)
}}

exception No_such_group

{shared{
  let name_of group = group.name
  let desc_of group = group.desc
}}

module type T = sig
  type t = shared_t

  val create : ?description:string -> string -> t Lwt.t
  val get : string -> t option Lwt.t

  val add_user : userid:int64 -> group:t -> unit Lwt.t
  val remove_user : userid:int64 -> group:t -> unit Lwt.t
  val in_group : userid:int64 -> group:t -> bool Lwt.t

  val all : unit -> t list Lwt.t

  val admin : t Lwt.t
end

module Make(M : sig
  module Database : Eba_db.T
end)
=
struct
  type t = shared_t

  let create_group_with (g : M.Database.G.t) =
    {
      id   = (Sql.get g#groupid);
      name = (Sql.get g#name);
      desc = (Sql.getn g#description);
    }

  module MCache_in = struct
    type key_t = string
    type value_t = t

    let compare = compare
    let get key =
      print_endline ("get with key="^key);
      match_lwt M.Database.G.does_group_exist key with
        | Some g -> Lwt.return (create_group_with g)
        | None -> Lwt.fail No_such_group
  end
  module MCache = Eba_cache.Make(MCache_in)

  (** creates the group in the database if it does
    * not exist, or returns its id as an abstract value *)
  let create ?description name =
    match_lwt M.Database.G.does_group_exist name with
     | Some g -> Lwt.return (create_group_with g)
     | None ->
         (* we can't use the cache here, because we can use create at top-level
          * and we don't have access to request scope at top-level *)
         lwt () = M.Database.G.new_group ?description name in
         lwt g = M.Database.G.get_group name in
         Lwt.return (create_group_with g)

  let get name =
    print_endline "eba_group.get";
    try_lwt
      lwt g = MCache.get name in
      Lwt.return (Some g)
    with
      | No_such_group -> Lwt.return None

  let add_user ~userid ~group =
    M.Database.G.add_user_in_group
      ~userid
      ~groupid:group.id

  let remove_user ~userid ~group =
    M.Database.G.remove_user_in_group
      ~userid
      ~groupid:group.id

  let in_group ~userid ~group =
    M.Database.G.is_user_in_group
      ~userid
      ~groupid:group.id

  let all () =
    lwt l = M.Database.G.all_groups () in
    let put_in_cache g =
      let g = create_group_with g in
      let () = MCache.set g.name g in
      g
    in
    Lwt.return
      (List.map
         (put_in_cache)
         (l))

  let admin = create "admin"
end
