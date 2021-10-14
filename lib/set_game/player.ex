defmodule SetGame.Player do
  defstruct id: nil, cards: [], code: [:color, :number, :bg, :figure]

  def new(id) do
    %__MODULE__{
      id: id,
      code: Enum.shuffle([:color, :number, :bg, :figure])
    }
  end

  def add_cards(%__MODULE__{} = player, cards) do
    %{player | cards: cards ++ player.cards}
  end

  def return_cards(%__MODULE__{} = player, num_cards \\ 1) do
    {returned_card, left_cards} = Enum.split(player.cards, num_cards)
    {returned_card, %{player | cards: left_cards}}
  end

  def score(%__MODULE__{cards: cards}), do: length(cards)
end
