# DAG

Directed Acyclic Graph (DAG) implementation in Elixir

As opposed to Erlang's [digraph](digraph) module, which uses an ETS
table, this library implements a DAG in a basic Elixir `%DAG{}`
struct, containing vertices and edges.

`:digraph` is great for large graphs, and for when you need *cyclic*
directed graphs; however the more simple acyclic graphs can be managed
more efficiently in a struct. Especially when they are not too
big. Note that this library is not optimized for performance in any
way.

[digraph]: http://erlang.org/doc/man/digraph.html


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dag` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dag, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dag](https://hexdocs.pm/dag).
