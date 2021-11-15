defmodule SetGame.GameServer do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient
  alias SetGame.Board
  alias SetGame.Player

  @timeout 60 * 60 * 24 * 1_000

  defmodule State do
    defstruct board: Board.new(), players: [], state: :players_joining
  end

  # Client

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(name \\ via_tuple(find_available_name())) do
    GenServer.start_link(__MODULE__, %State{}, name: name)
  end

  defp generate_name() do
    symbols = '23456789ABCDEFGHJKMNPQRSTUWXYZ'
    symbol_count = Enum.count(symbols)
    for _ <- 1..10, into: "", do: <<Enum.at(symbols, floor(:rand.uniform() * symbol_count))>>
  end

  def find_available_name() do
    name_candidate = generate_name()

    case Registry.lookup(Registry.SetGame, name_candidate) do
      [{_pid, _value}] -> find_available_name()
      [] -> name_candidate
    end
  end

  def get_uniq_name({:via, _, {_, name}}), do: name

  def get_uniq_name(pid) when is_pid(pid) do
    Registry.keys(Registry.SetGame, pid)
    |> Enum.at(0)
  end

  @spec via_tuple(any) :: {:via, Registry, {Registry.SetGame, any}}
  def via_tuple(name), do: {:via, Registry, {Registry.SetGame, name}}

  def call_set(pid, %Player{id: player_id}) do
    GenServer.call(pid, {:call_set, player_id})
  end

  def call_set(pid, player_id) do
    GenServer.call(pid, {:call_set, player_id})
  end

  def join(pid) do
    GenServer.call(pid, :join_player)
  end

  def player(pid, player_id) do
    GenServer.call(pid, {:player, player_id})
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def state(pid) do
    GenServer.call(pid, :get_state)
  end

  def table(pid), do: GenServer.call(pid, :table)

  def take_set(pid, %Player{id: player_id}, cards), do: take_set(pid, player_id, cards)

  def take_set(pid, player_id, [_card_a, _card_b, _card_c] = cards) do
    GenServer.call(pid, {:take_set, player_id, cards})
  end

  # Server
  @impl true
  def init(arg), do: {:ok, arg, @timeout}

  def child_spec(arg) do
    %{id: __MODULE__, restart: :transient, start: {__MODULE__, :start_link, [arg]}}
  end

  @impl true
  def handle_call(
        {:call_set, player_id},
        _from,
        %State{state: :playing} = state
      ) do
    case find_player_by_id(state, player_id) do
      nil ->
        reply_error(state, {:error, :no_player_found})

      player ->
        reply_success(%{state | state: {:set_called, player.id}})
    end
  end

  def handle_call({:call_set, _player_id}, _from, state) do
    reply_error(state, {:error, :cannot_call_set})
  end

  def handle_call(:get_state, _from, %State{state: game_state} = state) do
    reply_success(state, game_state)
  end

  def handle_call(:join_player, _from, %State{state: :players_joining} = state) do
    player = Player.new(length(state.players))
    reply_success(%{state | players: [player | state.players]}, player)
  end

  def handle_call(:join_player, _from, state) do
    reply_error(state, {:error, :no_new_players_allowed})
  end

  def handle_call({:player, id}, _form, state) do
    reply_success(state, find_player_by_id(state, id))
  end

  def handle_call(:start_game, _from, %State{state: :players_joining, players: players} = state)
      when length(players) > 0 do
    reply_success(%{state | state: :playing, board: Board.deal(state.board, 12)})
  end

  def handle_call(:start_game, _from, %State{state: :players_joining} = state) do
    reply_error(state, {:error, :no_players})
  end

  def handle_call(:start_game, _from, state) do
    reply_error(state, {:error, :already_started})
  end

  def handle_call(:table, _from, %State{board: board} = state) do
    reply_success(state, board.table)
  end

  def handle_call(
        {:take_set, player_id, [card_a, card_b, card_c] = cards},
        _from,
        %State{state: {:set_called, player_id}} = state
      ) do
    with %Player{} <- find_player_by_id(state, player_id),
         true <- Board.cards_are_on_table?(state.board, cards),
         true <- SetGame.Card.are_set?(card_a, card_b, card_c) do
      state
      |> Map.put(:state, :playing)
      |> board_move(cards)
      |> add_cards_to_player(player_id, cards)
      |> reply_success()
    else
      nil ->
        reply_error(state, {:error, :no_player_found})

      false ->
        reply_error(
          state |> Map.put(:state, :playing) |> return_cards_from_player(player_id, 1),
          {:error, :wrong_move, player_id}
        )
    end
  end

  def handle_call({:take_set, _, _}, _from, state),
    do: reply_error(state, {:error, :set_not_called})

  @impl true
  def handle_info(:timeout, state_data) do
    {:stop, {:shutdown, :timeout}, state_data}
  end

  defp reply_error(new_state, response) do
    {:reply, response, new_state, @timeout}
  end

  defp reply_success(new_state, response \\ :ok) do
    {:reply, response, new_state, @timeout}
  end

  defp board_move(%State{} = state, cards), do: %{state | board: Board.move(state.board, cards)}

  defp add_cards_to_player(%State{} = state, player_id, cards) do
    update_player(state, player_id, fn player ->
      %{player | cards: cards ++ player.cards}
    end)
  end

  defp return_cards_from_player(
         %State{players: players, board: board} = state,
         player_id,
         num_of_cards
       ) do
    player = find_player_by_id(players, player_id)
    {returned_cards, new_player} = Player.return_cards(player, num_of_cards)

    new_board = Board.add_cards(board, returned_cards)

    state
    |> update_player(player_id, new_player)
    |> Map.put(:board, new_board)
  end

  defp update_player(%State{} = state, player_id, %Player{} = new_player) do
    update_player(state, player_id, fn _ -> new_player end)
  end

  defp update_player(%State{players: players} = state, player_id, update_fn) do
    player_idx = find_player_index(players, player_id)
    new_players = List.update_at(players, player_idx, update_fn)
    %{state | players: new_players}
  end

  defp find_player_index(players, player_id) do
    Enum.find_index(players, fn el -> el.id == player_id end)
  end

  defp find_player_by_id(%State{} = state, player_id) do
    find_player_by_id(state.players, player_id)
  end

  defp find_player_by_id(players, player_id) do
    Enum.find(players, fn el -> el.id == player_id end)
  end
end
