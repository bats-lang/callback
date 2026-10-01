# callback

> **Superseded.** Host-fired callbacks are registered through
> [bridge](https://github.com/bats-lang/bridge)'s listener table (`listen`,
> `listen_document` and the rest, in
> [`src/event.bats`](https://github.com/bats-lang/bridge/blob/main/src/event.bats)).
> Use `#use wasm.bats-packages.dev/bridge` instead. No package depends on
> this one, and the repository is to be archived.

General-purpose callback registry. Callbacks are registered by integer ID
(0-127) and can be fired from the host with an integer payload.

## API

```
#use wasm.bats-packages.dev/callback as CB

(* Register a callback.
   id must be in 0..127; cb receives the payload integer. *)
$CB.register(id: int, cb: (int) -<cloptr1> void) : void

(* Fire a callback by ID with a payload *)
$CB.fire(id: int, payload: int) : void

(* Remove a callback by ID *)
$CB.remove(id: int) : void
```
