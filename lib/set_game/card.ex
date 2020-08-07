defmodule SetGame.Card do
  @enforce_keys [:color, :number, :shape, :shading]
  defstruct [:color, :number, :shape, :shading]

  def set?(cards) do
    cards
    |> Enum.map(&Map.values/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.uniq/1)
    |> Enum.map(&length/1)
    |> Enum.all?(fn count -> count != 2 end)
  end

  def generate_deck(colors: colors, numbers: numbers, shapes: shapes, shadings: shadings) do
    for color <- colors,
        number <- numbers,
        shape <- shapes,
        shading <- shadings,
        do: %__MODULE__{color: color, number: number, shape: shape, shading: shading}
  end
end
