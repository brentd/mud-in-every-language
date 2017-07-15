# A MUD in Every Language

This is a fun project intended as a base for exploring programming languages. I
think writing a MUD is a great way to get familiar with a language, as it
requires some fundamental concepts:

  * **Filesystem I/O**: for loading the world data into memory
  * **Networking**: TCP sockets so players can connect
  * **Concurrency**: simultaneous connected players are changing the state of the world,
    and the world itself changes independent of players
  * **Persistence**: many state changes to the world should survive server reboots
  * **Design**: MUDs are complex enough to require code organization and use of design patterns

In the `spec` directory is a Ruby RSpec suite of end-to-end tests that will
connect via TCP to a MUD server and perform inputs as a user. It is designed to
be a guide while developing an implementation.

Planned languages:

  * C
  * C++
  * C#
  * Objective-C
  * OCaml
  * Java
  * Scala
  * Swift
  * Io
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

For each language, the intention is to create at least one implementation using
only the language's standard library. Other variations can use interesting open-
source libraries, or other design paradigms (for example, an event-loop driven
server instead of threads). Code for each language should be idiomatic and
follow the spirit of the language as much as possible.

## Contributing

Because this is an exercise for my own personal development, I do not plan on
accepting pull requests, unless:

  * it's an improvement to the test suite
  * it provides suggestions of a more idiomatic way to write something in a
    language already implemented

If you'd like to have a go at implementing a language yourself, fork it and have
at it.
