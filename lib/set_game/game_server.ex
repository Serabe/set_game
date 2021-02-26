defmodule SetGame.GameServer do
  use GenServer

  alias SetGame.Match
  alias SetGame.Player

  defmodule State do
    defstruct match: Match.new(), players: [], state: :players_joining
  end

  # Client

  def start_link(_arg \\ nil) do
    GenServer.start_link(__MODULE__, %State{})
  end

  def call_set(pid, %Player{id: player_id}) do
    GenServer.call(pid, {:call_set, player_id})
  end

  def call_set(pid, player_id) do
    GenServer.call(pid, {:call_set, player_id})
  end

  def join(pid) do
    GenServer.call(pid, :join_player)
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def state(pid) do
    GenServer.call(pid, :get_state)
  end

  # Server
  @impl true
  def init(arg), do: {:ok, arg}

  @impl true
  def handle_call(
        {:call_set, player_id},
        _from,
        %State{state: :playing, players: players} = state
      ) do
    case Enum.find(players, fn el -> el.id == player_id end) do
      nil ->
        {:reply, {:error, :no_player_found}, state}

      player ->
        {:reply, :ok, %{state | state: {:set_called, player.id}}}
    end
  end

  def handle_call({:call_set, _player_id}, _from, state) do
    {:reply, {:error, :cannot_call_set}, state}
  end

  def handle_call(:get_state, _from, %State{state: game_state} = state) do
    {:reply, game_state, state}
  end

  def handle_call(:join_player, _from, %State{state: :players_joining} = state) do
    player = Player.new(length(state.players))
    {:reply, player, %{state | players: [player | state.players]}}
  end

  def handle_call(:join_player, _from, state) do
    {:reply, {:error, :no_new_players_allowed}, state}
  end

  def handle_call(:start_game, _from, %State{state: :players_joining, players: players} = state) do
    if length(players) > 0 do
      {:reply, :ok, %{state | state: :playing}}
    else
      {:reply, {:error, :no_players}, state}
    end
  end

  def handle_call(:start_game, _from, state) do
    {:reply, {:error, :already_started}, state}
  end
end
