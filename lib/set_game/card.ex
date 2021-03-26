defmodule SetGame.Card do
  @moduledoc """
  Cards in SET have four properties with three different values each. Therefore, the simplest
  way to represent a card (and generate all possible values) is represint it with an
  integer between 1 and 80 (80 = 3 ^ 4 - 1).

  If we want to generate cards based on values for each property, we can use `Integer.undigits`,
  that will parse and array of numbers as a number in the base given as the second parameter.
  `Integer.undigits([1, 0], 2)`  will return `2`, `Integer.undigits([1, 0], 3)` will return `3`
  and so on (remember, all bases are 10 in that same base :P).

  Given an integer we can get the digits in base 3 by using `unundigits => digits`.
  """

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
  def are_set?(card_a, card_a, card_a), do: false

  def are_set?(card_a, card_b, card_c) do
    [card_a, card_b, card_c]
    |> Enum.map(&num_to_props/1)
    |> Enum.zip()
    |> Enum.all?(&are_props_a_set?/1)
  end

  # Three properties satisfy the set condition (either all are the equal or all different) if
  # their sum is congruent modulo 3, which is the fancy mathematical term to mean the sum is
  # divisible by 3
  defp are_props_a_set?({a, b, c}) do
    rem(a + b + c, 3) === 0
  end

  defp num_to_props(n) do
    digits = n |> rem(81) |> Integer.digits(3)

    # Normalize the length of the array (always lead with 0).
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
