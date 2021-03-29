defmodule SetGame.Card do
  @number_of_attributes 4
  @options_per_attribute 3
  @max_number_of_cards round(:math.pow(@options_per_attribute, @number_of_attributes))

  @moduledoc """
  Cards in SET have four properties with three different values each. Therefore, the simplest
  way to represent a card (and generate all possible values) is represint it with an
  integer between 1 and 80 (80 = 3 ^ 4 - 1).

  If we want to generate cards based on values for each property, we can use `Integer.undigits`,
  that will parse an array of numbers as a number in the base given as the second parameter.
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

  def new_deck(), do: 0..(@max_number_of_cards - 1)

  # Three properties satisfy the set condition (either all are the equal or all different) if
  # their sum is congruent modulo 3, which is the fancy mathematical term to mean the sum is
  # divisible by 3
  defp are_props_a_set?({a, b, c}) do
    rem(a + b + c, @options_per_attribute) === 0
  end

  defp num_to_props(n) do
    n
    |> rem(@max_number_of_cards)
    |> Integer.digits(@options_per_attribute)
    |> pad()
  end

  defp pad(list) when length(list) < @number_of_attributes, do: pad([0 | list])
  defp pad(list), do: list
end
