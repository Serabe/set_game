defmodule SetGame.Mathy do
  @moduledoc """
  Mathy-like utilities
  """

  @doc """
  combination
  Groups items into the number requested and returns all possible combinations
  From https://github.com/aneta-bielska/set_game/blob/master/elixir/set_game.ex
  Takes a number of items to include in each group and the full set of items

    iex> SetGame.Mathy.combination(3, ["a", "b", "c", "d"])
    ...> [
    ...>   ["a", "b", "c"],
    ...>   ["a", "b", "d"],
    ...>   ["a", "c", "d"],
    ...>   ["b", "c", "d"]
    ...> ]
  """
  def combination(0, _), do: [[]]
  def combination(_, []), do: []
  def combination(n, [h|t]) do
    (for y <- combination(n - 1, t), do: [h|y]) ++ combination(n, t)
  end
end
