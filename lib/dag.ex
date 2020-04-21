defmodule DAG do
  @moduledoc File.read!("#{__DIR__}/../README.md")

  defstruct vs: MapSet.new(), es: []

  alias __MODULE__, as: M

  def new do
    {:ok, %M{}}
  end

  def add_vertex(%M{} = m, v) do
    {:ok, %M{m | vs: MapSet.put(m.vs, v)}}
  end

  def add_edge(%M{} = m, a, b) do
    with true <- MapSet.member?(m.vs, a),
         true <- MapSet.member?(m.vs, b),
         {:exists, false} <- {:exists, Enum.member?(m.es, {a, b})},
         {:path, false} <- {:path, path?(m, b, a)} do
      {:ok, %M{m | es: [{a, b} | m.es]}}
    else
      false ->
        {:error, :invalid}

      {:exists, true} ->
        {:ok, m}

      {:path, true} ->
        {:error, :cycle}
    end
  end

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

  def outgoing(%M{} = m, v) do
    m.es
    |> Enum.filter(&(elem(&1, 0) == v))
    |> Enum.map(&elem(&1, 1))
  end

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
end
