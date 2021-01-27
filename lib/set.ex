defmodule SetGame.Set do
  @moduledoc """
  Utilities to work with a possible set.
  A set is defined as valid if either all of the card properties are the same or all of the card properties are different.
  """

  @doc """
  verify
  Takes in a list of cards and returns whether they form a valid set.

  iex> SetGame.Set.verify([
  ...>   %SetGame.Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
  ...>   %SetGame.Card{color: :red, number: 1, shape: :oval, pattern: :solid},
  ...>   %SetGame.Card{color: :purple, number: 3, shape: :square, pattern: :polka}
  ...> ])
  :true

  """
  def verify(cards) do
    check_property(cards, :color) and check_property(cards, :number) and check_property(cards, :pattern) and check_property(cards, :shape)
  end

  defp check_property(cards, property) do
    cards
    |> get_unique_property_values(property)
    |> Enum.count()
    |> is_allowed_set?(Enum.count(cards))
  end

  defp get_unique_property_values(cards, property) do
    cards
    |> Enum.map(fn card -> Map.get(card, property) end)
    |> Enum.frequencies()
    |> Map.keys()
  end


  defp is_allowed_set?(1, _cards), do: true
  defp is_allowed_set?(unique_count, total_cards) when unique_count === total_cards, do: true
  defp is_allowed_set?(_unique_count, _total_cards), do: false

end
