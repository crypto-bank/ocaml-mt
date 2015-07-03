module Timestamp = struct
  class ['ts] t ts =
    object
      method ts : 'ts = ts
    end

  let compare t t' = compare t#ts t'#ts
end

module Direction = struct
  type dir = [`Unset | `Bid | `Ask] [@@deriving show,enum]
  let dir_of_enum_exn d = match dir_of_enum d with
    | Some d -> d
    | None -> invalid_arg "dir_of_enum"

  class t d =
    object
      method d : dir = d
    end

  let compare t t' = compare t#d t'#d
end

module Tick = struct
  module T = struct
    class ['p] t ~p ~v =
      object
        method p : 'p = p
        method v : 'p = v
      end

    let compare t t' = compare t#p t'#p
  end

  module TD = struct
    class ['p] t ~p ~v ~d =
      object
        inherit Direction.t d
        inherit ['p] T.t p v
      end

    let compare t t' = compare t#p t'#p
  end

  module TTS = struct
    class ['p, 'ts] t ~ts ~p ~v =
      object
        inherit ['ts] Timestamp.t ts
        inherit ['p] T.t p v
      end

    let compare t t' = compare t#p t'#p
  end

  module TDTS = struct
    class ['p, 'ts] t ~ts ~p ~v ~d =
      object
        inherit Direction.t d
        inherit ['ts] Timestamp.t ts
        inherit ['p] T.t p v
      end

    let compare t t' = compare t#p t'#p
    let show o =
      let ts = Int64.(div o#ts 1_000_000_000L) in
      let ns = Int64.(rem o#ts 1_000_000_000L) in
      Format.sprintf "< ts = %Ld.%Ld, p = %Ld, v = %Ld, d = %s >"
        ts ns o#p o#v (Direction.show_dir o#d)

    let pp fmt o =
      let ts = Int64.(div o#ts 1_000_000_000L) in
      let ns = Int64.(rem o#ts 1_000_000_000L) in
      Format.fprintf fmt "< ts = %Ld.%Ld, p = %Ld, v = %Ld, d = %a >"
        ts ns o#p o#v Direction.pp_dir o#d
  end
end

module Ticker = struct
  module T = struct
    class ['ts, 'p] t ~last ~bid ~ask ~high ~low ~volume ~ts =
      object
        method last : 'p = last
        method bid : 'p = bid
        method ask : 'p = ask
        method high : 'p = high
        method low : 'p = low
        method volume : 'p = volume
        method timestamp : 'ts = ts
      end
  end

  module Tvwap = struct
    class ['ts, 'p] t ~vwap ~last ~bid ~ask ~high ~low ~volume ~ts =
      object
        inherit ['ts, 'p] T.t ~last ~bid ~ask ~high ~low ~volume ~ts
        method vwap : 'p = vwap
      end
  end
end
