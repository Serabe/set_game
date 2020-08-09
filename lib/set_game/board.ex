defmodule SetGame.Board do
  defstruct deck: [], table: []

  @doc """
  Generate a new board

  ## Example
      iex> %SetGame.Board{} = SetGame.Board.new()
  """
  def new() do
    %SetGame.Board{
      deck: Enum.shuffle(0..80),
      table: []
    }
  end

  @doc """
  Generates the next move replacing the given positions.
  Rules are not enforced at this level.
  """
  def move(%SetGame.Board{table: table} = board, {_, _, _} = positions) do
    new_table =
      positions |> Tuple.to_list() |> Enum.reduce(table, &List.update_at(&2, &1, fn _ -> nil end))

    deal(%{board | table: new_table})
  end

  @doc """
  Deals cards from the top of the deck

  ## Example
      iex> %SetGame.Board{} = SetGame.Board.deal(SetGame.Board.new())
  """
  def deal(
        %SetGame.Board{deck: deck, table: table} = board,
        cards_to_deal \\ nil
      ) do
    cards_to_deal = cards_to_deal || number_of_cards_to_deal(board)

    %SetGame.Board{
      deck: Enum.drop(deck, cards_to_deal),
      table: update_table(table, Enum.take(deck, cards_to_deal))
    }
  end

  defp update_table(table, new_elements) do
    Enum.reduce(new_elements, table, &add_element_to_table/2)
  end

  defp add_element_to_table(element, table) do
    case Enum.find_index(table, &is_nil/1) do
      nil -> List.insert_at(table, -1, element)
      index -> List.update_at(table, index, fn _ -> element end)
    end
  end

  def number_of_cards_to_deal(%SetGame.Board{table: table}) do
    cards_on_table = Enum.count(table)

    cond do
      # If we have more than 12 cards, we complete to the nearest multiple of 3
      cards_on_table >= 12 -> 3 - rem(cards_on_table, 3)
      # Otherwise we complete to 12 cards
      true -> 12 - cards_on_table
    end
  end
end
