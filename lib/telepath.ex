defmodule Telepath do
  @moduledoc """
  Provide an easy way to access to elixir's data struct with a path.

  Inspired by JsonPath or xPath (for json and xml), Telepath allow you to reach
  the data that you want by specifying a path.

  The path can be created using the sigils ~t (see `Telepath.sigil_t/2`).

  ```elixir
  # Simple path to reach data under the map key `"data"`.
  ~r/data/

  # Same but for map with atom instead of string.
  ~r/data/a
  ```

  ## Modifiers

  The modifiers available when creating a Telepath are:

  - atom (a) - enable atom key for path exploration.
  """

  @regex ~r/^\w+|[0-9]+/

  @doc """
  Transform the struct path to an array that define how to
  access to the data.

  > Use `~r` instead of `&Telepath.sigil_t/2`.

  ...

  E.g
      iex> Telepath.sigil_t("node")
      ["node"]

      iex> Telepath.sigil_t("node.attr1")
      ["node", "attr1"]

      iex> Telepath.sigil_t("node[0]")
      ["node", 0]

      iex> Telepath.sigil_t("node[0].attr1")
      ["node", 0, "attr1"]

      iex> Telepath.sigil_t("node.0.attr1")
      ["node", "0", "attr1"]

  You cal also manage atom based map using 'a' opts.

  E.g.

      iex> Telepath.sigil_t("node[0].attr1", 'a')
      [:node, 0, :attr1]
  """
  def sigil_t(string, opts \\ []) do
    String.split(string, ".")
    |> Enum.map(fn p ->
      [node | array_pos] =
        @regex
        |> Regex.scan(p)
        |> List.flatten()

      array_pos = Enum.map(array_pos, &String.to_integer/1)

      if Enum.member?(opts, ?a) do
        [String.to_atom(node) | array_pos]
      else
        [node | array_pos]
      end
    end)
    |> List.flatten()
  end

  @doc false
  def get(data, []), do: data

  def get(data, _) when not is_map(data) and not is_list(data) do
    nil
  end

  def get(data, [x | expression]) when is_list(data) and is_integer(x) do
    data
    |> Enum.at(x)
    |> get(expression)
  end

  def get(data, expression) when is_list(data) do
    Enum.map(data, &get(&1, expression))
  end

  def get(data, [x | expresion]) when is_map(data) do
    data
    |> Map.get(x)
    |> get(expresion)
  end
end