defmodule MathyTest do
  use ExUnit.Case
  doctest SetGame.Mathy

  alias SetGame.Mathy

  test "combination: returns all possible combinations" do
    options = ["a", "b", "c", "d"]

    assert Mathy.combination(0, options) == [[]]
    assert Mathy.combination(1, options) == [["a"], ["b"], ["c"], ["d"]]
    assert Mathy.combination(2, options) ==  [
      ["a", "b"],
      ["a", "c"],
      ["a", "d"],
      ["b", "c"],
      ["b", "d"],
      ["c", "d"]
    ]
    assert Mathy.combination(3, options) ==  [
      ["a", "b", "c"],
      ["a", "b", "d"],
      ["a", "c", "d"],
      ["b", "c", "d"]
    ]
  end
end
