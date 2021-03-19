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
    if card_a == card_b || card_b == card_c || card_c == card_a do
      false
    else
      [card_a, card_b, card_c]
      |> Enum.map(&num_to_props/1)
      |> Enum.zip()
      |> Enum.all?(&are_props_a_set?/1)
    end
  end

  defp are_props_a_set?({a, b, c}) do
    rem(a + b + c, 3) === 0
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
