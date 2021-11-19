defmodule SetGame.GameSupervisorTest do
  use ExUnit.Case
  doctest SetGame.GameSupervisor

  alias SetGame.{GameServer, GameSupervisor}

  def game_alive?(pid) when is_pid(pid), do: Process.alive?(pid)

  def game_alive?(name) do
    case name |> GenServer.whereis() do
      nil -> false
      pid -> Process.alive?(pid)
    end
  end

  describe "#start_game" do
    test "starts a valid game that can be played" do
      {:ok, pid} = GameSupervisor.start_game()

      assert game_alive?(pid)

      player1 = GameServer.join(pid)

      GameServer.start_game(pid)

      GameServer.call_set(pid, player1)

      # We've played a bit
      assert game_alive?(pid)

      GameSupervisor.stop_game(pid)

      refute game_alive?(pid)
    end

    test "starts several games with different names" do
      {:ok, pid1} = GameSupervisor.start_game()
      {:ok, pid2} = GameSupervisor.start_game()
      name1 = GameServer.get_uniq_name(pid1)
      name2 = GameServer.get_uniq_name(pid2)

      refute name1 == name2

      GameSupervisor.stop_game(pid1)
      GameSupervisor.stop_game(pid2)
    end
  end

  describe "#stop_game" do
    test "stops the game process" do
      {:ok, pid} = GameSupervisor.start_game()

      assert game_alive?(pid)

      GameSupervisor.stop_game(pid)

      refute game_alive?(pid)
    end

    test "only stops the given game process" do
      {:ok, pid1} = GameSupervisor.start_game()
      {:ok, pid2} = GameSupervisor.start_game()

      assert game_alive?(pid1)
      assert game_alive?(pid2)

      GameSupervisor.stop_game(pid1)

      refute game_alive?(pid1)
      assert game_alive?(pid2)

      GameSupervisor.stop_game(pid2)
    end

    test "stop persisting data once we stop a game" do
      {:ok, pid} = GameSupervisor.start_game()
      name = GameServer.get_uniq_name(pid)

      assert game_alive?(pid)
      assert [_result] = :ets.lookup(:set_game_state, name)

      GameSupervisor.stop_game(pid)

      refute game_alive?(pid)
      assert [] = :ets.lookup(:set_game_state, name)
    end
  end
end
