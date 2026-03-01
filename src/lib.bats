(* callback -- general-purpose callback registry for bats *)
(* Integer ID registry (0-127). Callbacks can be fired from host. *)

#include "share/atspre_staload.hats"

(* ============================================================
   Public API
   ============================================================ *)

#pub fun register
  (id: int, cb: (int) -<cloref1> void): void

#pub fun fire
  (id: int, payload: int): void

#pub fun remove
  (id: int): void

(* WASM export -- JS calls this to fire a callback *)
#pub fun on_callback
  (id: int, payload: int): void = "ext#bats_on_callback"

(* ============================================================
   C runtime -- closure table
   ============================================================ *)

$UNSAFE begin
%{#
#ifndef _CALLBACK_RUNTIME_DEFINED
#define _CALLBACK_RUNTIME_DEFINED
#define _CALLBACK_MAX 128
static void *_callback_table[_CALLBACK_MAX] = {0};

static void _callback_set(int id, void *cb) {
  if (id >= 0 && id < _CALLBACK_MAX) _callback_table[id] = cb;
}

static void *_callback_get(int id) {
  if (id >= 0 && id < _CALLBACK_MAX) return _callback_table[id];
  return (void*)0;
}
#endif
%}

(* ============================================================
   Implementation
   ============================================================ *)

implement
register(id, cb) = let
  val cbp = $UNSAFE.castvwtp0{ptr}(cb)
in $extfcall(void, "_callback_set", id, cbp) end

implement
fire(id, payload) = let
  val cbp = $extfcall(ptr, "_callback_get", id)
in
  if ptr_isnot_null(cbp) then let
    val cb = $UNSAFE.cast{(int) -<cloref1> void}(cbp)
    val () = cb(payload)
  in () end
  else ()
end

implement
remove(id) =
  $extfcall(void, "_callback_set", id, the_null_ptr)

implement
on_callback(id, payload) =
  fire(id, payload)

(* ============================================================
   Static tests
   ============================================================ *)

fn _test_register_fire_remove(): void = let
  val () = register(0, lam (payload: int): void =<cloref1> let val _ = payload in () end)
  val () = fire(0, 42)
  val () = remove(0)
in () end

end (* $UNSAFE *)
