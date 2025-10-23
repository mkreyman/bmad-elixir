defmodule BmadElixirTest do
  use ExUnit.Case
  doctest BmadElixir

  test "greets the world" do
    assert BmadElixir.hello() == :world
  end
end
