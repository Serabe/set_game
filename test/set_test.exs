defmodule SetTest do
  use ExUnit.Case
  doctest SetGame.Set

  alias SetGame.Card
  alias SetGame.Set

  # TODO - would want to make these sets a little more comprehensive

  test "verifies set if all properties are the same" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined}
    ]

    assert Set.verify(cards) == :true
  end

  test "verifies set if all properties are the different" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 1, shape: :oval, pattern: :solid},
      %Card{color: :purple, number: 3, shape: :square, pattern: :polka}
    ]

    assert Set.verify(cards) == :true
  end

  test "verifies set if properties either match or are different" do
    cards = [
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 2, shape: :squiggle, pattern: :solid},
      %Card{color: :purple, number: 2, shape: :squiggle, pattern: :polka}
    ]

    assert Set.verify(cards) == :true
  end

  test "does not verify if one property does not follow the rules" do
    cards = [
      %Card{color: :blue, number: 1, shape: :squiggle, pattern: :outlined},
      %Card{color: :red, number: 2, shape: :squiggle, pattern: :solid},
      %Card{color: :purple, number: 2, shape: :squiggle, pattern: :polka}
    ]

    assert Set.verify(cards) == :false
  end

  test "can validate when the total cards are not three" do
    cards = [
      %Card{color: :blue, number: 1, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 2, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 3, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 4, shape: :squiggle, pattern: :outlined},
      %Card{color: :blue, number: 5, shape: :squiggle, pattern: :outlined}
    ]

    assert Set.verify(cards) == :true
  end
end
