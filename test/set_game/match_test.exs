defmodule SetGame.MatchTest do
  use ExUnit.Case
  doctest SetGame.Match
  alias SetGame.Board
  alias SetGame.Match

  describe "#move" do
    test "with invalid positions, return {:invalid_input, match}" do
      match = %Match{
        board: %Board{
          deck: Enum.to_list(13..80),
          table: Enum.to_list(1..9)
        }
      }

      assert {:invalid_input, _match} = Match.move(match, {0, 1, 10})
      assert {:invalid_input, _match} = Match.move(match, {0, 10, 1})
      assert {:invalid_input, _match} = Match.move(match, {10, 1, 4})
    end

    test "with positions without cards, return {:invalid_input, match}" do
      match = %Match{
        board: %Board{
          deck: Enum.to_list(13..80),
          table: [0, 1, nil, 3, nil, nil, 6, 7, 8, 9]
        }
      }

      assert {:invalid_input, _match} = Match.move(match, {0, 2, 7})
      assert {:invalid_input, _match} = Match.move(match, {0, 1, 4})
      assert {:invalid_input, _match} = Match.move(match, {5, 1, 8})
    end

    test "if positions form a set, return {:set, new_match, [some_cards]}" do
      match = %Match{
        board: %Board{
          deck: Enum.to_list(50..80),
          table: [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            Integer.undigits([1, 0, 0, 0], 3),
            Integer.undigits([0, 0, 0, 0], 3),
            Integer.undigits([2, 0, 0, 0], 3)
          ]
        }
      }

      assert {:set, new_match, [card_a, card_b, card_c]} = Match.move(match, {9, 10, 11})
      assert new_match.board.table == [1, 2, 3, 4, 5, 6, 7, 8, 9, 50, 51, 52]
      assert new_match.board.deck == Enum.to_list(53..80)
      assert card_a == Integer.undigits([1, 0, 0, 0], 3)
      assert card_b == Integer.undigits([0, 0, 0, 0], 3)
      assert card_c == Integer.undigits([2, 0, 0, 0], 3)
    end

    test "if positions are valid but do not form a set, return {:invalid_move, match}" do
      match = %Match{
        board: %Board{
          deck: Enum.to_list(50..80),
          table: [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            Integer.undigits([1, 0, 0, 0], 3),
            Integer.undigits([1, 0, 0, 0], 3),
            Integer.undigits([2, 0, 0, 0], 3)
          ]
        }
      }

      assert {:invalid_move, _match} = Match.move(match, {9, 10, 11})
    end
  end
end
