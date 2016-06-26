# A MUD in Every Language

_...at least, every language that interests me!_

This is a fun project intended as a base for exploring programming languages.
It's my opinion that writing a MUD is one of the best ways to get familiar with
a language quickly, as it requires use of some fundamental concepts:

  * **Filesystem I/O** (for loading the world data into memory)
  * **Networking** (TCP Sockets so players can connect e.g. via telnet)
  * **Concurrency** (simultaneous players are changing the state of the world,
    and the world itself is constantly changing independent of players)
  * **Persistence** (most state changes to the world should survive server reboots)
  * **Design** (MUDs are complex enough to require at least some code organization)

In the `spec` directory is a Ruby RSpec suite of end-to-end tests that will
connect to a any server implementation and perform inputs like a user. It is
designed to be a guide while developing the implementation, even gamifying the
process by poviding goals and a tight feedback loop.

Planned languages:

  * C
  * C++
  * C#
  * Objective-C
  * OCaml
  * Java
  * Scala
  * Swift
  * Lua
  * Ruby
  * Python
  * Go
  * Clojure
  * Common Lisp
  * Rust
  * Erlang
  * Elixir
  * Haskell
  * Javascript (Node.js)

For each language, the intention is to create one implementation using the
language's standard library as much as possible, and afterward create further
variations in other subdirectories using interesting open-source libraries, or
other design approaches (for example, an event-loop driven server instead of
threads).

Because this is an exercise for my own personal development, I do not plan on
accepting pull requests, unless it is an improvement to the test suite, or
provides suggestions of a more idiomatic way to write something in a given
language. If this project does actually interest anyone else out there, do feel
free to fork it and have a go at any language you want, though!
