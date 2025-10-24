defmodule BmadElixirTest do
  use ExUnit.Case, async: true
  doctest BmadElixir

  describe "version/0" do
    test "returns the package version" do
      version = BmadElixir.version()
      assert is_binary(version)
      assert version =~ ~r/^\d+\.\d+\.\d+/
    end
  end
end
