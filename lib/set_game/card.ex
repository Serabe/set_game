defmodule SetGame.Card do
  @doc """
  Given three cards, returns whether they are a valid set or not.

  A valid set is a lot of three cards where, for each property, either they all
  share the same value, or none of them have the same.

  ## Examples
      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0, 1, 2, 1], 3),
      ...>   Integer.undigits([0,1,2,0], 3),
      ...>   Integer.undigits([0,1,2,2], 3)
      ...> )
      true

      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0,1,2,1], 3),
      ...>   Integer.undigits([1,1,1,0], 3),
      ...>   Integer.undigits([2,1,0,2], 3)
      ...> )
      true

      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0,1,2,1], 3),
      ...>   Integer.undigits([1,1,1,1], 3),
      ...>   Integer.undigits([2,1,0,2], 3)
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0,1,2,1], 3),
      ...>   Integer.undigits([1,1,2,0], 3),
      ...>   Integer.undigits([2,1,0,2], 3)
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0,1,2,1], 3),
      ...>   Integer.undigits([1,2,1,0], 3),
      ...>   Integer.undigits([2,1,0,2], 3)
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   Integer.undigits([0,1,2,1], 3),
      ...>   Integer.undigits([1,1,1,0], 3),
      ...>   Integer.undigits([0,1,0,2], 3)
      ...> )
      false
  """
  def are_set?(card_a, card_b, card_c) do
    Enum.zip([
      num_to_props(card_a),
      num_to_props(card_b),
      num_to_props(card_c)
    ])
    |> Enum.all?(&are_props_a_set?/1)
  end

  defp are_props_a_set?({a, a, a}), do: true

  defp are_props_a_set?({a, b, c}) do
    a != b && b != c && c != a
  end

  defp num_to_props(n) do
    digits = n |> rem(81) |> Integer.digits(3)

    case Enum.count(digits) do
      1 ->
        [0, 0, 0] ++ digits

      2 ->
        [0, 0] ++ digits

      3 ->
        [0] ++ digits

      4 ->
        digits
    end
  end
end
