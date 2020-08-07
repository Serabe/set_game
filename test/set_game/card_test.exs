defmodule SetGame.CardTest do
  alias SetGame.Card
  use ExUnit.Case

  describe "set?" do
    test "is a set if everything is different" do
      cards = [
        %Card{shape: :oval, color: :red, number: 1, shading: :solid},
        %Card{shape: :squiggle, color: :purple, number: 2, shading: :striped},
        %Card{shape: :diamond, color: :green, number: 3, shading: :outlined}
      ]

      assert(Card.set?(cards), "should be a set")
    end

    test "is a set if everything either the same or different" do
      cards = [
        %Card{shape: :oval, color: :red, number: 1, shading: :solid},
        %Card{shape: :oval, color: :purple, number: 2, shading: :striped},
        %Card{shape: :oval, color: :green, number: 3, shading: :outlined}
      ]

      assert(Card.set?(cards), "should be a set")
    end

    test "is not a set if 2 out of 3 are the same in a property" do
      cards = [
        %Card{shape: :oval, color: :red, number: 1, shading: :solid},
        %Card{shape: :oval, color: :purple, number: 2, shading: :striped},
        %Card{shape: :squiggle, color: :green, number: 3, shading: :outlined}
      ]

      refute(Card.set?(cards), "should not be a set")
    end
  end
end
