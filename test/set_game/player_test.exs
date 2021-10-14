defmodule SetGame.PlayerTest do
  use ExUnit.Case
  doctest SetGame.Player
  alias SetGame.Player

  describe "#add_cards" do
    test "cards are added to player.cards" do
      player = Player.new("some-id")

      assert length(player.cards) == 0

      new_player = Player.add_cards(player, [3, 7, 8])

      assert length(new_player.cards) == 3
    end

    test "cards are added at the beginning of player.cards" do
      player =
        Player.new("some-id")
        |> Player.add_cards([1, 2, 3])
        |> Player.add_cards([4, 5])

      assert player.cards == [4, 5, 1, 2, 3]
    end
  end

  describe "#return_cards" do
    test "returns the returned cards and the new player" do
      {returned_cards, player} =
        Player.new("some-id")
        |> Player.add_cards([1, 2, 3])
        |> Player.return_cards(2)

      assert returned_cards == [1, 2]
      assert player.cards == [3]
    end

    test "return all the cards if there are not enough cards to return" do
      {returned_cards, player} =
        Player.new("some-id")
        |> Player.add_cards([1, 2, 3])
        |> Player.return_cards(4)

      assert returned_cards == [1, 2, 3]
      assert player.cards == []
    end

    test "by default, return one card" do
      {returned_cards, player} =
        Player.new("some-id")
        |> Player.add_cards([1, 2, 3])
        |> Player.return_cards()

      assert returned_cards == [1]
      assert player.cards == [2, 3]
    end
  end

  describe "#score" do
    test "returns the length of the cards" do
      player =
        Player.new("some-id")
        |> Player.add_cards([1, 2, 3])

      assert Player.score(player) == 3

      new_player = Player.add_cards(player, [4, 5])

      assert Player.score(new_player) == 5
    end
  end
end
