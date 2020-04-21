defmodule DAG do
  @moduledoc File.read!("#{__DIR__}/../README.md")

  defstruct vs: MapSet.new(), es: MapSet.new()

  alias __MODULE__, as: M

  @doc """
  Creates an empty DAG.
  """
  def new do
    {:ok, %M{}}
  end

  @doc """
  Add a vertex to the DAG.
  """
  def add_vertex(%M{} = m, v) do
    {:ok, %M{m | vs: MapSet.put(m.vs, v)}}
  end

  @doc """
  Return the list of vertices in no particular order.
  """
  def vertices(%M{} = m) do
    Enum.to_list(m.vs)
  end

  @doc """
  Return the list of edges in no particular order.
  """
  def edges(%M{} = m) do
    Enum.to_list(m.es)
  end

  @doc """
  Add an edge between two vertices.

  The vertices must already exist in the DAG, otherwise an error is
  returned. An error is also returned when the edge would form a
  cycle.
  """
  def add_edge(%M{} = m, a, b) do
    with true <- Enum.member?(m.vs, a),
         true <- Enum.member?(m.vs, b),
         {:exists, false} <- {:exists, Enum.member?(m.es, {a, b})},
         {:path, false} <- {:path, path?(m, b, a)} do
      {:ok, %M{m | es: MapSet.put(m.es, {a, b})}}
    else
      false ->
        {:error, :invalid}

      {:exists, true} ->
        {:ok, m}

      {:path, true} ->
        {:error, :cycle}
    end
  end

  @doc """
  Returns true when there is a path between the given vertices
  """
  def path?(%M{} = m, a, b) do
    case Enum.member?(m.es, {a, b}) do
      true ->
        true

      false ->
        outgoing(m, a)
        |> Enum.reduce_while(
          false,
          fn v, _ ->
            case path?(m, v, b) do
              true -> {:halt, true}
              false -> {:cont, false}
            end
          end
        )
    end
  end

  @doc """
  Return the outgoing edges
  """
  def outgoing(%M{} = m, v) do
    m.es
    |> Enum.filter(&(elem(&1, 0) == v))
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Return the list over vertices, sorted topologically

  The order between non-connected vertices is arbitrarily decided;
  however it is stable between sorts.
  """
  def topsort(%M{} = m) do
    m.vs
    |> Enum.sort(fn a, b ->
      cond do
        path?(m, a, b) ->
          false

        path?(m, b, a) ->
          true

        true ->
          a < b
      end
    end)
  end

  @doc """
  Split the DAG into its components, returning a list of independent DAGs.
  """
  def components(%M{} = m) do
    components(Enum.to_list(m.vs), m.es, [])
  end

  defp components([], _edges, acc) do
    acc
  end

  defp components([v | rest], edges, acc) do
    component_edges = edges |> Enum.filter(fn {a, b} -> a == v or b == v end)
    m = from_edges(v, component_edges)
    rest = rest -- Enum.to_list(m.vs)
    components(rest, edges, [m | acc])
  end

  defp from_edges(v, edges) do
    vs = edges |> Enum.map(&Tuple.to_list/1) |> List.flatten()
    %M{vs: MapSet.new([v | vs]), es: MapSet.new(edges)}
  end
end
