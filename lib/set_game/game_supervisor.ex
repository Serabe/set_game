defmodule SetGame.GameSupervisor do
  use DynamicSupervisor

  alias SetGame.GameServer

  def start_game() do
    name = GameServer.find_available_name() |> GameServer.via_tuple()

    case DynamicSupervisor.start_child(
           __MODULE__,
           GameServer.child_spec(name)
         ) do
      {:ok, _pid, _info} -> {:ok, name}
      {:ok, _pid} -> {:ok, name}
      other -> other
    end
  end

  def stop_game(name) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

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
