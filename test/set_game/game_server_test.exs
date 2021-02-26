defmodule SetGame.GameServerTest do
  use ExUnit.Case
  doctest SetGame.GameServer

  alias SetGame.GameServer
  alias SetGame.Player

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
end
