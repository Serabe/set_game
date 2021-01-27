defmodule SetGameTest do
  use ExUnit.Case
  doctest SetGame

  alias SetGame.Card

  test "create sets up a game" do
    {in_play, remaining_deck} = SetGame.create()

    assert Enum.count(in_play) == 12
    assert Enum.count(remaining_deck) == 69
  end

  test "remove_set_from_play removes the specified cards from the cards in play" do
    card1 =%Card{color: :blue, number: 3, pattern: :striped, shape: :oval}
    card2 = %Card{color: :red, number: 2, pattern: :solid, shape: :diamond}
    card3 = %Card{color: :green, number: 3, pattern: :striped, shape: :squiggle}
    card4 = %Card{color: :blue, number: 1, pattern: :outlined, shape: :oval}
    card5 = %Card{color: :red, number: 3, pattern: :solid, shape: :squiggle}

    assert SetGame.remove_set_from_play([card1, card2, card3, card4, card5], [card1, card5]) == [card2, card3, card4]
  end

  test "deal: will update the cards in play to be the full playing size" do
    {in_play, remaining_deck} = SetGame.create()
    current_hand = Enum.take(in_play, 5)

    {updated_hand, updated_remaining} = SetGame.deal(remaining_deck, current_hand)

    assert Enum.count(updated_hand) == 12
    assert Enum.count(updated_remaining) == 62
  end

  test "deal: will update the cards in play as much as possible not enough cards are left in deck" do
    {in_play, remaining_deck} = SetGame.create()
    current_hand = Enum.take(in_play, 5)

    {updated_hand, updated_remaining} = SetGame.deal(Enum.take(remaining_deck,3), current_hand)

    assert Enum.count(updated_hand) == 8
    assert Enum.count(updated_remaining) == 0
  end

  # Should use a mock or something rather than just doing this again
  test "valid_set?: returns true for a valid set" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka}
    ]

    assert SetGame.valid_set?(cards) == :true
  end

  test "valid_set?: returns false for an invalid set" do
    cards = [
      %Card{color: :blue, number: 1, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka}
    ]

    assert SetGame.valid_set?(cards) == :false
  end

  test "has_valid_sets? returns true if valid sets remain in cards" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka},
      %Card{color: :blue, number: 1, shape: :square, pattern: :polka}
    ]

    assert SetGame.has_valid_sets?(cards) == :true
  end


  test "has_valid_sets? returns false if no valid sets remain in cards" do
    cards = [
      %Card{color: :blue, number: 1, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka},
      %Card{color: :blue, number: 1, shape: :square, pattern: :polka}
    ]

    assert SetGame.has_valid_sets?(cards) == :false
  end

  test "get_valid_sets? returns remaining valid sets in cards" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka},
      %Card{color: :blue, number: 1, shape: :square, pattern: :polka}
    ]

    expected = [[
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka}
    ]]

    assert SetGame.get_valid_sets(cards) == expected
  end

  test "get_valid_sets? returns empty list when no valid sets in cards" do
    cards = [
      %Card{color: :blue, number: 1, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka},
      %Card{color: :blue, number: 1, shape: :square, pattern: :polka}
    ]

    assert SetGame.get_valid_sets(cards) == []
  end
end
