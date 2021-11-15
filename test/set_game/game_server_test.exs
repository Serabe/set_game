defmodule SetGame.GameServerTest do
  use ExUnit.Case
  doctest SetGame.GameServer

  alias SetGame.GameServer
  alias SetGame.Player

  describe "#table" do
    test "at init, it is empty" do
      {:ok, pid} = GameServer.start_link()

      assert [] == GameServer.table(pid)
    end

    test "when game starts, table is filled" do
      {:ok, pid} = GameServer.start_link()
      GameServer.join(pid)
      GameServer.start_game(pid)

      table = GameServer.table(pid)

      assert length(table) == 12
      assert Enum.all?(table, &is_integer/1)
    end
  end

  describe "#call_set" do
    test "if player can call the set, do it" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      assert :ok == GameServer.call_set(pid, player)
    end

    test "if player can call the set, do it (using only the id)" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      assert :ok == GameServer.call_set(pid, player.id)
    end

    test "if player is not in game, return error" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      assert {:error, :no_player_found} ==
               GameServer.call_set(pid, %{player | id: "some random thing"})
    end

    test "if game has not started, set cannot be called" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)

      assert {:error, :cannot_call_set} == GameServer.call_set(pid, player)
    end

    test "if game has a set called, cannot call another one until it is resolved" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      assert :ok == GameServer.call_set(pid, player)

      assert {:error, :cannot_call_set} == GameServer.call_set(pid, player)
    end
  end

  describe "#join" do
    test "if players are allowed, return player" do
      {:ok, pid} = GameServer.start_link()

      player = GameServer.join(pid)

      assert %Player{} = player
    end

    test "if players are not allowed to join, return :no_new_players_allowed" do
      {:ok, pid} = GameServer.start_link()
      GameServer.join(pid)
      GameServer.start_game(pid)

      assert {:error, :no_new_players_allowed} = GameServer.join(pid)
    end
  end

  describe "#player" do
    test "if no player with the given id is found, return nil" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)

      assert is_nil(GameServer.player(pid, "not #{id}"))
    end

    test "return player if found" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      assert ^player = GameServer.player(pid, player.id)
    end
  end

  describe "#start_game" do
    test "return :ok if game can start" do
      {:ok, pid} = GameServer.start_link()
      GameServer.join(pid)
      assert :ok == GameServer.start_game(pid)
    end

    test "return :no_players error if there are no players" do
      {:ok, pid} = GameServer.start_link()

      assert {:error, :no_players} == GameServer.start_game(pid)
    end

    test "return :already_started error if the game is already started" do
      {:ok, pid} = GameServer.start_link()
      GameServer.join(pid)
      GameServer.start_game(pid)

      assert {:error, :already_started} = GameServer.start_game(pid)
    end
  end

  describe "#take_set" do
    test "return {:error, :set_not_called} if set was not called by the user" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)

      table = GameServer.table(pid)
      set = Enum.at(find_set(table), 0)

      assert {:error, :set_not_called} = GameServer.take_set(pid, id, set)
    end

    test "return {:error, :set_not_called} if player taking it is different than the one that called it" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id_a} = GameServer.join(pid)
      %Player{id: id_b} = GameServer.join(pid)
      GameServer.start_game(pid)

      table = GameServer.table(pid)
      set = Enum.at(find_set(table), 0)

      :ok = GameServer.call_set(pid, id_a)
      assert {:error, :set_not_called} = GameServer.take_set(pid, id_b, set)
    end

    test "return {:error, :wrong_move, player_id} if the move is not valid (cards not on the table)" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)
      :ok = GameServer.call_set(pid, id)

      table = GameServer.table(pid)
      card_not_on_table = Enum.find(1..81, fn el -> !Enum.member?(table, el) end)

      assert {:error, :wrong_move, ^id} = GameServer.take_set(pid, id, [1, 2, card_not_on_table])
      assert :playing = GameServer.state(pid)
    end

    test "returns cards from player if they have any (cards not on table)" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)

      table = GameServer.table(pid)
      set = Enum.at(find_set(table), 0)

      :ok = GameServer.call_set(pid, id)
      :ok = GameServer.take_set(pid, id, set)

      player = GameServer.player(pid, id)
      assert 3 = SetGame.Player.score(player)

      card_not_on_table = Enum.find(1..81, fn el -> !Enum.member?(table, el) end)

      :ok = GameServer.call_set(pid, id)
      assert {:error, :wrong_move, ^id} = GameServer.take_set(pid, id, [1, 2, card_not_on_table])
      assert :playing = GameServer.state(pid)

      player = GameServer.player(pid, id)
      assert 2 = SetGame.Player.score(player)
    end

    test "return {:error, :wrong_move, player_id} if the move is not valid (cards are not set)" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)
      :ok = GameServer.call_set(pid, id)

      table = GameServer.table(pid)
      not_a_set = Enum.at(find_not_set(table), 0)

      assert {:error, :wrong_move, ^id} = GameServer.take_set(pid, id, not_a_set)
      assert :playing = GameServer.state(pid)
    end

    test "returns cards from player if they have any (cards are not set)" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)

      table = GameServer.table(pid)
      set = Enum.at(find_set(table), 0)

      :ok = GameServer.call_set(pid, id)
      :ok = GameServer.take_set(pid, id, set)

      player = GameServer.player(pid, id)
      assert 3 = SetGame.Player.score(player)

      table = GameServer.table(pid)
      not_a_set = Enum.at(find_not_set(table), 0)

      :ok = GameServer.call_set(pid, id)
      assert {:error, :wrong_move, ^id} = GameServer.take_set(pid, id, not_a_set)
      assert :playing = GameServer.state(pid)

      player = GameServer.player(pid, id)
      assert 2 = SetGame.Player.score(player)
    end

    test "return :ok if move was successful" do
      {:ok, pid} = GameServer.start_link()
      %Player{id: id} = GameServer.join(pid)
      GameServer.start_game(pid)
      :ok = GameServer.call_set(pid, id)

      table = GameServer.table(pid)
      set = Enum.at(find_set(table), 0)

      assert :ok = GameServer.take_set(pid, id, set)
      assert :playing = GameServer.state(pid)

      assert %Player{cards: ^set} = GameServer.player(pid, id)

      new_table = GameServer.table(pid)
      old_table_without_set = Enum.filter(table, fn el -> !Enum.member?(set, el) end)

      assert Enum.all?(old_table_without_set, fn el -> Enum.member?(new_table, el) end)
    end

    defp find_set(table) do
      for card_a <- table,
          card_b <- table,
          card_c <- table,
          SetGame.Card.are_set?(card_a, card_b, card_c),
          do: [card_a, card_b, card_c]
    end

    defp find_not_set(table) do
      for card_a <- table,
          card_b <- table,
          card_c <- table,
          !SetGame.Card.are_set?(card_a, card_b, card_c),
          do: [card_a, card_b, card_c]
    end
  end

  describe "#state" do
    test "return :players_joining when game is created" do
      {:ok, pid} = GameServer.start_link()

      assert :players_joining == GameServer.state(pid)
    end

    test "return :playing once the game has started" do
      {:ok, pid} = GameServer.start_link()
      GameServer.join(pid)
      GameServer.start_game(pid)

      assert :playing == GameServer.state(pid)
    end

    test "return :set_called and the player id if a set is being called" do
      {:ok, pid} = GameServer.start_link()
      player = GameServer.join(pid)
      GameServer.start_game(pid)

      GameServer.call_set(pid, player)

      assert {:set_called, player.id} == GameServer.state(pid)
    end
  end

  describe "#get_uniq_name" do
    test "returns the uniq name for a via tuple" do
      assert "hola" == GameServer.get_uniq_name(GameServer.via_tuple("hola"))
    end

    test "returns the uniq name for a pid" do
      {:ok, pid} = GameServer.start_link(GameServer.via_tuple("hola"))
      assert is_pid(pid)

      assert "hola" == GameServer.get_uniq_name(pid)
    end
  end
end
