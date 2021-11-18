defmodule SetGame.GameSupervisorTest do
  use ExUnit.Case
  doctest SetGame.GameSupervisor

  alias SetGame.{GameServer, GameSupervisor}

  def game_alive?(name) do
    case name |> GenServer.whereis() do
      nil -> false
      pid -> Process.alive?(pid)
    end
  end

  describe "#start_game" do
    test "starts a valid game that can be played" do
      {:ok, name} = GameSupervisor.start_game()

      assert game_alive?(name)

      player1 = GameServer.join(name)

      GameServer.start_game(name)

      GameServer.call_set(name, player1)

      # We've played a bit
      assert game_alive?(name)

      GameSupervisor.stop_game(name)

      refute game_alive?(name)
    end

    test "starts several games with different names" do
      {:ok, name1} = GameSupervisor.start_game()
      {:ok, name2} = GameSupervisor.start_game()

      refute name1 == name2

      GameSupervisor.stop_game(name1)
      GameSupervisor.stop_game(name2)
    end
  end

  describe "#stop_game" do
    test "stops the game process" do
      {:ok, name1} = GameSupervisor.start_game()

      assert game_alive?(name1)

      GameSupervisor.stop_game(name1)

      refute game_alive?(name1)
    end

    test "only stops the given game process" do
      {:ok, name1} = GameSupervisor.start_game()
      {:ok, name2} = GameSupervisor.start_game()

      assert game_alive?(name1)
      assert game_alive?(name2)

      GameSupervisor.stop_game(name1)

      refute game_alive?(name1)
      assert game_alive?(name2)

      GameSupervisor.stop_game(name2)
    end

    test "stop persisting data once we stop a game" do
      {:ok, name} = GameSupervisor.start_game()
      uniq_name = GameServer.get_uniq_name(name)

      assert game_alive?(name)
      assert [_result] = :ets.lookup(:set_game_state, uniq_name)

      GameSupervisor.stop_game(name)

      refute game_alive?(name)
      assert [] = :ets.lookup(:set_game_state, uniq_name)
    end
  end
end
