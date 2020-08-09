defmodule SetGame.Card do
  defstruct background: 0, color: 0, form: 0, number: 0

  @doc """
  Creates a card from a number. Since there are only 81 possible cards,
  all numbers will go through a remainder of 81.

  This gives us a compact way of representing the cards.

  ## Examples
      iex> SetGame.Card.from_number(0)
      %SetGame.Card{background: 0, color: 0, form: 0, number: 0}

      iex> SetGame.Card.from_number(3)
      %SetGame.Card{background: 0, color: 0, form: 1, number: 0}

      iex> SetGame.Card.from_number(5)
      %SetGame.Card{background: 0, color: 0, form: 1, number: 2}

      iex> SetGame.Card.from_number(15)
      %SetGame.Card{background: 0, color: 1, form: 2, number: 0}

      iex> SetGame.Card.from_number(38)
      %SetGame.Card{background: 1, color: 1, form: 0, number: 2}
  """
  def from_number(n) do
    [bg, color, form, number] = num_to_props(n)

    %SetGame.Card{background: bg, color: color, form: form, number: number}
  end

  @doc """
  Given a card, it returns the number we used to create it.
  It's the inverse function of SetGame.Card.from_number/1

  ## Examples
      iex> SetGame.Card.to_number(SetGame.Card.from_number(14))
      14

      iex> SetGame.Card.to_number(SetGame.Card.from_number(32))
      32

      iex> SetGame.Card.to_number(SetGame.Card.from_number(69))
      69
  """
  def to_number(%SetGame.Card{background: bg, color: c, form: f, number: n}) do
    Integer.undigits([bg, c, f, n], 3)
  end

  @doc """
  Given three cards, returns whether they are a valid set or not.

  A valid set is a lot of three cards where, for each property, either they all
  share the same value, or none of them have the same.

  ## Examples
      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 0},
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 2}
      ...> )
      true

      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 1, color: 1, form: 1, number: 0},
      ...>   %SetGame.Card{ background: 2, color: 1, form: 0, number: 2}
      ...> )
      true

      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 1, color: 1, form: 1, number: 1},
      ...>   %SetGame.Card{ background: 2, color: 1, form: 0, number: 2}
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 1, color: 1, form: 2, number: 0},
      ...>   %SetGame.Card{ background: 2, color: 1, form: 0, number: 2}
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 1, color: 2, form: 1, number: 0},
      ...>   %SetGame.Card{ background: 2, color: 1, form: 0, number: 2}
      ...> )
      false

      iex> SetGame.Card.are_set?(
      ...>   %SetGame.Card{ background: 0, color: 1, form: 2, number: 1},
      ...>   %SetGame.Card{ background: 1, color: 1, form: 1, number: 0},
      ...>   %SetGame.Card{ background: 0, color: 1, form: 0, number: 2}
      ...> )
      false
  """
  def are_set?(%SetGame.Card{} = card_a, %SetGame.Card{} = card_b, %SetGame.Card{} = card_c) do
    cards = [card_a, card_b, card_c]

    [:background, :color, :form, :number]
    |> Enum.all?(fn prop ->
      are_props_a_set?(cards |> Enum.map(&Map.get(&1, prop)))
    end)
  end

  defp are_props_a_set?([a, a, a]), do: true

  defp are_props_a_set?([a, b, c]) do
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
