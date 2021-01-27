defmodule SetGame.Deck do
  @moduledoc """
  A deck of cards to be used for a game of set
  """
  alias SetGame.Card

  @doc """
  prepare
  Creates a deck of cards optionally specifying card properties to use

  iex> SetGame.Deck.prepare()
  iex> SetGame.Deck.prepare(
  ...>  [42, 45, 90],
  ...>  [:black, :purple, :teal],
  ...>  [:triangle, :pentagon, :rectangle],
  ...>  [:plaid, :polka, :shaded]
  ...> )
  """
  def prepare(numbers \\ 1..3, colors \\ ~w(red blue green)a, shapes \\ ~w(oval squiggle diamond)a, patterns \\ ~w(solid striped outlined)a) do
    create(numbers, colors, shapes, patterns)
    |> Enum.shuffle()
  end

  @doc """
  deal
  Deals a deck and returns a list of cards in play and a list of cards remaining

    iex> SetGame.Deck.deal([:card, :card1, :card2], 2)
    {[:card, :card1], [:card2]}
  """
  def deal(deck, number) do
    deck
    |> Enum.split(number)
  end

  defp create(numbers, colors, shapes, patterns) do
    # Given a three properties of three options each, create a card for each type
    Enum.flat_map(numbers, fn number ->
      Enum.flat_map(colors, fn color ->
        Enum.flat_map(shapes, fn shape ->
          Enum.map(patterns, fn pattern ->
            %Card{color: color, number: number, shape: shape, pattern: pattern}
          end)
        end)
      end)
    end)
  end
end
