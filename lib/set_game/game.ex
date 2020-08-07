defmodule SetGame.Game do
  alias SetGame.Card

  @enforce_keys [:deck, :board]
  defstruct [:deck, :board]

  @defaults [
    colors: [:red, :purple, :green],
    numbers: [1, 2, 3],
    shapes: [:oval, :squiggle, :diamond],
    shadings: [:solid, :striped, :outlined]
  ]

  def new(options \\ []) do
    (options ++ @defaults)
    |> Card.generate_deck()
    |> Enum.shuffle()
    |> settle_board([])
  end

  def over?(game) do
    !board_has_a_set?(game.board)
  end

  def make_set(game, cards) do
    with {:ok} <- check_cards_are_on_board(cards, game.board),
         {:ok} <- check_cards_make_a_set(cards) do
      new_board =
        game.board
        |> Enum.reject(fn card -> card in cards end)

      {:ok, settle_board(game.deck, new_board)}
    end
  end

  def put_back(game, card) do
    %__MODULE__{
      deck: game.deck,
      board: game.board ++ [card]
    }
  end

  defp settle_board(deck, board) do
    {deck, board} = fill_board_to_minimum(deck, board)
    {deck, board} = add_cards_if_no_sets(deck, board)

    %__MODULE__{deck: deck, board: board}
  end

  defp fill_board_to_minimum(deck, board) when length(board) < 12 do
    deal_cards(deck, board, 12 - length(board))
  end

  defp fill_board_to_minimum(deck, board), do: {deck, board}

  defp add_cards_if_no_sets([], board), do: {[], board}

  defp add_cards_if_no_sets(deck, board) do
    if board_has_a_set?(board) do
      {deck, board}
    else
      {deck, board} = deal_cards(deck, board, 3)
      add_cards_if_no_sets(deck, board)
    end
  end

  defp board_has_a_set?(board) do
    comb(3, board) |> Enum.any?(fn cards -> Card.set?(cards) end)
  end

  # https://rosettacode.org/wiki/Combinations#Elixir
  defp comb(0, _), do: [[]]
  defp comb(_, []), do: []

  defp comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end

  defp check_cards_are_on_board(cards, board) do
    if Enum.all?(cards, fn card -> card in board end) do
      {:ok}
    else
      {:error, "One or more of the selected cards is not on the board."}
    end
  end

  defp check_cards_make_a_set(cards) do
    if Card.set?(cards) do
      {:ok}
    else
      {:error, "The chosen cards do not make a set."}
    end
  end

  defp deal_cards(deck, board, count) do
    {dealt_cards, remaining_deck} = deck |> Enum.split(count)

    {remaining_deck, board ++ dealt_cards}
  end
end
