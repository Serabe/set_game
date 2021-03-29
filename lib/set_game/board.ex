defmodule SetGame.Board do
  defstruct deck: [], table: []

  alias SetGame.Card

  @doc """
  Generate a new board

  ## Example
      iex> %SetGame.Board{} = SetGame.Board.new()
  """
  def new() do
    %SetGame.Board{
      deck: Enum.shuffle(Card.new_deck()),
      table: []
    }
  end

  @doc """
  Generates the next move replacing the given positions.
  Rules are not enforced at this level.
  """
  def move(%SetGame.Board{table: table} = board, [_, _, _] = cards) do
    new_table =
      Enum.map(table, fn el ->
        if Enum.member?(cards, el) do
          nil
        else
          el
        end
      end)

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

  def add_cards(%__MODULE__{table: table} = board, cards) do
    %{board | table: update_table(table, cards)}
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

  def cards_are_on_table?(%__MODULE__{} = board, cards \\ []) do
    Enum.all?(cards, &Enum.member?(board.table, &1))
  end
end
