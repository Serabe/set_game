defmodule SetGame.GameSupervisor do
  use DynamicSupervisor

  alias SetGame.GameServer

  def start_game(name \\ :ok) do
    DynamicSupervisor.start_child(
      __MODULE__,
      GameServer.child_spec(name)
    )
  end

  def stop_game(name_or_pid) do
    :ets.delete(:set_game_state, GameServer.get_uniq_name(name_or_pid))
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name_or_pid))
  end

  defp pid_from_name(pid) when is_pid(pid), do: pid

  defp pid_from_name({:via, _, {_, name}}),
    do: pid_from_name(name)

  defp pid_from_name(name) when is_binary(name),
    do: name |> GameServer.via_tuple() |> GenServer.whereis()

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
