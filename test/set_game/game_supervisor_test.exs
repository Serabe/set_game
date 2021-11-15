defmodule SetGame.GameSupervisorTest do
  use ExUnit.Case
  doctest SetGame.GameSupervisor

  alias SetGame.{GameServer, GameSupervisor}

  def game_alive?(name) do
    case name |> GameServer.via_tuple() |> GenServer.whereis() do
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
    end
  end
end
