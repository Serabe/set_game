defmodule SetGame.GameTest do
  alias SetGame.{Card, Game}
  use ExUnit.Case

  describe "new" do
    test "it generates a deck and deals out 12 cards to the board" do
      :rand.seed(:exrop, {1, 2, 3})

      game = Game.new()

      assert(Enum.count(game.deck) == 69)
      assert(Enum.count(game.board) == 12)
    end
  end

  describe "make_set" do
    test "it removes the set and replenishes the board when the selected cards are a set" do
      game = %Game{
        deck: [
          %Card{color: :green, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        ],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ]
      }

      {status, game} =
        Game.make_set(game, [
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ])

      assert(status == :ok)

      assert(
        game.deck == [
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        ]
      )

      assert(
        game.board == [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 1, shape: :diamond, shading: :solid}
        ]
      )
    end

    test "it deals additional cards if there is no set on the board after removing the selected cards" do
      game = %Game{
        deck: [
          %Card{color: :green, number: 1, shape: :squiggle, shading: :outlined},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :outlined},
          %Card{color: :red, number: 2, shape: :squiggle, shading: :striped},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :diamon, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamon, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamon, shading: :solid}
        ],
        board: [
          %Card{color: :green, number: 1, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 2, shape: :diamond, shading: :striped},
          %Card{color: :red, number: 1, shape: :oval, shading: :outlined},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :squiggle, shading: :striped},
          %Card{color: :green, number: 3, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :striped},
          %Card{color: :green, number: 2, shape: :oval, shading: :outlined},
          %Card{color: :green, number: 2, shape: :diamond, shading: :outlined},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ]
      }

      {status, game} =
        Game.make_set(game, [
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ])

      assert(status == :ok)

      assert(
        game.deck == [
          %Card{color: :green, number: 1, shape: :diamon, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamon, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamon, shading: :solid}
        ]
      )

      assert(
        game.board == [
          %Card{color: :green, number: 1, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 2, shape: :diamond, shading: :striped},
          %Card{color: :red, number: 1, shape: :oval, shading: :outlined},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :squiggle, shading: :striped},
          %Card{color: :green, number: 3, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :striped},
          %Card{color: :green, number: 2, shape: :oval, shading: :outlined},
          %Card{color: :green, number: 2, shape: :diamond, shading: :outlined},
          %Card{color: :green, number: 1, shape: :squiggle, shading: :outlined},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :outlined},
          %Card{color: :red, number: 2, shape: :squiggle, shading: :striped},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid}
        ]
      )
    end

    test "it does not replenish the board if nothing is left" do
      game = %Game{
        deck: [],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ]
      }

      {status, game} =
        Game.make_set(game, [
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ])

      assert(status == :ok)

      assert(game.deck == [])

      assert(
        game.board == [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid}
        ]
      )
    end

    test "is an error when the selected cards are not a set" do
      game = %Game{
        deck: [
          %Card{color: :green, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        ],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid}
        ]
      }

      result =
        Game.make_set(game, [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid}
        ])

      assert(result == {:error, "The chosen cards do not make a set."})
    end

    test "is an error when one of the selected cards is not on the board" do
      game = %Game{
        deck: [
          %Card{color: :green, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        ],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid}
        ]
      }

      result =
        Game.make_set(game, [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :squiggle, shading: :solid}
        ])

      assert(result == {:error, "One or more of the selected cards is not on the board."})
    end
  end

  describe "over?" do
    test "a game is not over if there is still a set on the board" do
      game = %Game{
        deck: [],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid}
        ]
      }

      refute(Game.over?(game))
    end

    test "a game is over if there are no sets on the board" do
      game = %Game{
        deck: [],
        board: [
          %Card{color: :green, number: 1, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 2, shape: :diamond, shading: :striped},
          %Card{color: :red, number: 1, shape: :oval, shading: :outlined},
          %Card{color: :red, number: 1, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :squiggle, shading: :striped},
          %Card{color: :green, number: 3, shape: :squiggle, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :striped},
          %Card{color: :green, number: 2, shape: :oval, shading: :outlined},
          %Card{color: :green, number: 2, shape: :diamond, shading: :outlined},
          %Card{color: :green, number: 1, shape: :squiggle, shading: :outlined},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :outlined},
          %Card{color: :red, number: 2, shape: :squiggle, shading: :striped}
        ]
      }

      assert(Game.over?(game))
    end
  end

  describe "put_back" do
    test "it puts the card on the board" do
      game = %Game{
        deck: [],
        board: [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid}
        ]
      }

      new_game =
        Game.put_back(
          game,
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        )

      assert(
        new_game.board == [
          %Card{color: :red, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 2, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :red, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :purple, number: 3, shape: :diamond, shading: :solid},
          %Card{color: :green, number: 1, shape: :oval, shading: :solid},
          %Card{color: :red, number: 1, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 1, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :oval, shading: :solid},
          %Card{color: :red, number: 2, shape: :oval, shading: :solid},
          %Card{color: :purple, number: 2, shape: :oval, shading: :solid},
          %Card{color: :green, number: 3, shape: :oval, shading: :solid},
          %Card{color: :green, number: 2, shape: :diamond, shading: :solid}
        ]
      )
    end
  end
end
