defmodule VectorTest do
  use ExUnit.Case, async: true

  test "Vector.add returns correct result given two binaries" do
    assert Vector.add(<<1, 2, 3>>, <<1, 2, 3>>) == <<2, 4, 6>>
  end
  test "Vector.bit_and returns correct result given two binaries" do
    assert Vector.bit_and(<<1, 1, 1>>, <<3, 3, 3>>) == <<1, 1, 1>>
  end
  test "Vector.inner returns correct result given two binaries" do
    assert Vector.inner(<<1, 2, 3>>, <<1, 2, 3>>) == 14
  end
  test "Vector.outer returns correct result given two binaries" do
    assert Vector.outer(<<1, 2, 3>>, <<1, 2, 3>>) ==
      <<
        1, 2, 3,
        2, 4, 6,
        3, 6, 9
      >>
  end
  test "Vector.subtract returns correct result given two binaries" do
    assert Vector.subtract(<<1, 2, 3>>, <<1, 2, 3>>) == <<0, 0, 0>>
  end
  test "Vector.xor returns correct result given two binaries" do
    assert Vector.xor(<<1, 1, 1>>, <<3, 3, 3>>) == <<2, 2, 2>>
  end

  test "Vector.add returns correct result given two lists" do
    assert Vector.add([1, 1, 1], [2, 2, 2]) == [3, 3, 3]
  end
  test "Vector.bit_and returns correct result given two lists" do
    assert Vector.bit_and([1, 1, 1], [3, 3, 3]) == [1, 1, 1]
  end
  test "Vector.inner returns correct result given two lists" do
    assert Vector.inner([1, 1, 1], [2, 2, 2]) == 6
  end
  test "Vector.outer returns correct result given two lists" do
    assert Vector.outer([1, 2, 3], [1, 2, 3]) ==
      [
        1, 2, 3,
        2, 4, 6,
        3, 6, 9
      ]
  end
  test "Vector.subtract returns correct result given two lists" do
    assert Vector.subtract([1, 2, 3], [1, 2, 3]) == [0, 0, 0]
  end
  test "Vector.xor returns correct result given two lists" do
    assert Vector.xor([1, 1, 1], [3, 3, 3]) == [2, 2, 2]
  end
end
