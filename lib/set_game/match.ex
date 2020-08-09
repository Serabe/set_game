defmodule SetGame.Match do
  defstruct board: SetGame.Board.new()

  @doc """
  Creates new Match
  """
  def new(), do: %SetGame.Match{board: SetGame.Board.new()}

  @doc """
  Given a match and a 3-tuple of positions, return the new state of the game
  """
  def move(%SetGame.Match{} = match, {_, _, _} = card_positions) do
    cond do
      !valid_positions?(match, card_positions) ->
        {:invalid_input, match}

      cards_form_a_set?(match, card_positions) ->
        {:set, %{match | board: SetGame.Board.move(match.board, card_positions)},
         cards_for_positions(match, card_positions)}

      true ->
        {:invalid_move, match}
    end
  end

  defp cards_for_positions(match, positions) do
    positions |> Tuple.to_list() |> Enum.map(&Enum.at(match.board.table, &1))
  end

  defp cards_form_a_set?(match, positions) do
    [a, b, c] = cards_for_positions(match, positions)

    SetGame.Card.are_set?(a, b, c)
  end

  defp valid_positions?(%SetGame.Match{} = match, {_, _, _} = card_positions) do
    cards_on_table = Enum.count(match.board.table)

    card_positions
    |> Tuple.to_list()
    |> Enum.all?(fn pos ->
      pos < cards_on_table && !is_nil(Enum.at(match.board.table, pos))
    end)
  end
end
