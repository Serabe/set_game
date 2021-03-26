defmodule SetGame.GameServer do
  use GenServer

  alias SetGame.Board
  alias SetGame.Player

  defmodule State do
    defstruct board: Board.new(), players: [], state: :players_joining
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
  def init(arg), do: {:ok, arg}

  @impl true
  def handle_call(
        {:call_set, player_id},
        _from,
        %State{state: :playing} = state
      ) do
    case find_player_by_id(state, player_id) do
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

  def handle_call({:player, id}, _form, state) do
    {:reply, find_player_by_id(state, id), state}
  end

  def handle_call(:start_game, _from, %State{state: :players_joining, players: players} = state) do
    if length(players) > 0 do
      {:reply, :ok, %{state | state: :playing, board: Board.deal(state.board, 12)}}
    else
      {:reply, {:error, :no_players}, state}
    end
  end

  def handle_call(:start_game, _from, state) do
    {:reply, {:error, :already_started}, state}
  end

  def handle_call(:table, _from, %State{board: board} = state) do
    {:reply, board.table, state}
  end

  def handle_call(
        {:take_set, player_id, [card_a, card_b, card_c] = cards},
        _from,
        %State{state: {:set_called, player_id}} = state
      ) do
    with %Player{} <- find_player_by_id(state, player_id),
         true <- Board.cards_are_on_table?(state.board, cards),
         true <- SetGame.Card.are_set?(card_a, card_b, card_c) do
      {:reply, :ok,
       state
       |> Map.put(:state, :playing)
       |> board_move(cards)
       |> add_cards_to_player(player_id, cards)}
    else
      nil ->
        {:reply, {:error, :no_player_found}, state}

      false ->
        {
          :reply,
          {:error, :wrong_move, player_id},
          state |> Map.put(:state, :playing) |> return_cards_from_player(player_id, 1)
        }
    end
  end

  def handle_call({:take_set, _, _}, _from, state), do: {:reply, {:error, :set_not_called}, state}

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
