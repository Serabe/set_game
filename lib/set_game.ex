defmodule SetGame do
  alias SetGame.Deck
  alias SetGame.Set
  alias SetGame.Mathy

  @cards_in_play 12
  @set_size 3

  @moduledoc """
  Provides basic API access for Set Game.
  https://en.wikipedia.org/wiki/Set_(card_game)
  """

  @doc """
  Creates a game instance
    iex> SetGame.create()
  """
  def create() do
    Deck.prepare()
    # returns cards in play and then the rest of the deck
    |> Deck.deal(@cards_in_play)
  end

  @doc """
  Removes cards from those that are in play
  """
  def remove_set_from_play(in_play, cards_to_remove) do
    in_play
    |> Enum.reject(fn card -> Enum.member?(cards_to_remove, card) end)
  end

  @doc """
  Deal to bring the number of cards in play back upto the full amount after removing a set
  """
  def deal(deck, in_play) do
    number_to_deal = @cards_in_play - Enum.count(in_play)
    {cards_to_add, deck} = Deck.deal(deck, number_to_deal)
    {in_play ++ cards_to_add, deck}
  end

  @doc """
  Test to see whether a list of cards is a valid "Set"
  """
  def valid_set?(cards) do
    Set.verify(cards)
  end

  @doc """
  Test to see whether there are any valid "sets" in a list of cards
  """
  def has_valid_sets?(cards) do
    get_valid_sets(cards) !== []
  end

  @doc """
  Returns all valid "sets" in a list of cards
  """
  def get_valid_sets(cards) do
    Mathy.combination(@set_size, cards)
    |> Enum.filter(fn possible -> valid_set?(possible) end)
  end
end
