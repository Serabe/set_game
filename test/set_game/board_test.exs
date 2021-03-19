defmodule SetGame.BoardTest do
  use ExUnit.Case
  doctest SetGame.Board

  alias SetGame.Board

  describe "#new" do
    test "generates a new board" do
      board = Board.new()

      assert Enum.count(board.deck) == 81
      assert Enum.all?(board.deck, &(&1 < 81))
      assert Enum.count(board.table) == 0
    end
  end

  describe "deal/1" do
    test "after a normal set recollection, deal the top three cards on the table" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..19)
      }

      after_deal = Board.deal(board)

      assert Enum.count(after_deal.deck) == 2
      assert after_deal.deck == [5, 6]
      assert Enum.count(after_deal.table) == 12
      assert Enum.member?(after_deal.table, 1)
      assert Enum.member?(after_deal.table, 2)
      assert Enum.member?(after_deal.table, 3)
    end

    test "if there are an _odd_ number of cards, complete until 12" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..18)
      }

      after_deal = Board.deal(board)

      assert Enum.count(after_deal.deck) == 1
      assert after_deal.deck == [6]
      assert Enum.count(after_deal.table) == 12
      assert Enum.member?(after_deal.table, 1)
      assert Enum.member?(after_deal.table, 2)
      assert Enum.member?(after_deal.table, 3)
      assert Enum.member?(after_deal.table, 5)
    end

    test "if there are 12 cards, deal 3 more" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..22)
      }

      after_deal = Board.deal(board)

      assert Enum.count(after_deal.deck) == 2
      assert after_deal.deck == [5, 6]
      assert Enum.count(after_deal.table) == 15
      assert Enum.member?(after_deal.table, 1)
      assert Enum.member?(after_deal.table, 2)
      assert Enum.member?(after_deal.table, 3)
    end

    test "if there are 13 cards, deal 2 more" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..23)
      }

      after_deal = Board.deal(board)

      assert Enum.count(after_deal.deck) == 3
      assert after_deal.deck == [3, 5, 6]
      assert Enum.count(after_deal.table) == 15
      assert Enum.member?(after_deal.table, 1)
      assert Enum.member?(after_deal.table, 2)
    end

    test "if there are 17 cards, deal 1 more" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..27)
      }

      after_deal = Board.deal(board)

      assert Enum.count(after_deal.deck) == 4
      assert after_deal.deck == [2, 3, 5, 6]
      assert Enum.count(after_deal.table) == 18
      assert Enum.member?(after_deal.table, 1)
    end

    test "if there are empty positions in the table, fill them" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: [11, 12, nil, 14, 15, nil, nil, 18, 19, 20, 21, 22]
      }

      after_deal = Board.deal(board)

      assert after_deal.table == [11, 12, 1, 14, 15, 2, 3, 18, 19, 20, 21, 22]
    end

    test "the second parameter modifies the number of cards dealt" do
      board = %Board{
        deck: [1, 2, 3, 5, 6],
        table: Enum.to_list(11..19)
      }

      after_deal = Board.deal(board, 4)

      assert after_deal.deck == [6]
      assert after_deal.table == Enum.to_list(11..19) ++ [1, 2, 3, 5]
    end
  end

  describe "#move" do
    test "changes the given cards" do
      board = %Board{
        deck: Enum.to_list(1..10),
        table: Enum.to_list(11..22)
      }

      after_move = Board.move(board, [12, 17, 15])

      assert after_move.deck == Enum.to_list(4..10)
      assert after_move.table == [11, 1, 13, 14, 2, 16, 3, 18, 19, 20, 21, 22]
    end
  end
end
