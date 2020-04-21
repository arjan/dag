defmodule DAGgTest do
  use ExUnit.Case
  doctest DAG
  import DAG

  test "new" do
    assert {:ok, %DAG{}} = new()
  end

  test "add vertex" do
    {:ok, dag} = new()
    {:ok, dag1} = add_vertex(dag, :a)
    {:ok, ^dag1} = add_vertex(dag1, :a)

    assert [:a] == vertices(dag1)

    {:ok, dag2} = add_vertex(dag1, :b)
    assert [:a, :b] == vertices(dag2)
  end

  test "add edge" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok

    assert {:ok, dag1} = add_edge(dag, :a, :b)
    assert {:ok, ^dag1} = add_edge(dag1, :a, :b)
  end

  test "add edge w/ cycle" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok(&add_vertex(&1, :c))
      |> ok(&add_edge(&1, :a, :b))
      |> ok(&add_edge(&1, :b, :c))
      |> ok

    assert {:error, :cycle} = add_edge(dag, :b, :a)
    assert {:error, :cycle} = add_edge(dag, :c, :a)
  end

  test "path?" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok(&add_edge(&1, :a, :b))
      |> ok

    assert path?(dag, :a, :b)
    refute path?(dag, :b, :a)
  end

  test "path? multihop" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok(&add_vertex(&1, :c))
      |> ok(&add_vertex(&1, :d))
      |> ok(&add_edge(&1, :a, :b))
      |> ok(&add_edge(&1, :b, :c))
      |> ok(&add_edge(&1, :c, :d))
      |> ok

    assert path?(dag, :a, :c)
    assert path?(dag, :b, :d)
    assert path?(dag, :a, :d)
    refute path?(dag, :d, :a)
  end

  test "topsort" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :d))
      |> ok(&add_vertex(&1, :c))
      |> ok(&add_vertex(&1, :b))
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_edge(&1, :a, :b))
      |> ok(&add_edge(&1, :b, :c))
      |> ok(&add_edge(&1, :c, :d))
      |> ok

    assert ~w(d c b a)a = topsort(dag)
  end

  test "components" do
    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok

    assert [ma, mb] = Enum.sort(components(dag))
    assert [:a] = vertices(ma)
    assert [:b] = vertices(mb)

    dag =
      new()
      |> ok(&add_vertex(&1, :a))
      |> ok(&add_vertex(&1, :b))
      |> ok(&add_edge(&1, :a, :b))
      |> ok

    assert [^dag] = components(dag)
  end

  ###

  defp ok({:ok, result}), do: result
  defp ok({:ok, result}, cb), do: cb.(result)
end
