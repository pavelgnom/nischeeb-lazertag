defmodule NischeebLazertagBackend.CollisionsTest do
  use ExUnit.Case

  alias NischeebLazertag.{Player, Collisions}

  test "should handle collisions" do
    players = %{
      {2, 3, 4, 5} => %Player{address: {2, 3, 4, 5}, x: 1.0, y: 0.0},
      {3, 4, 5, 6} => %Player{address: {3, 4, 5, 6}, x: 0.0, y: 1.0},
      {4, 5, 6, 7} => %Player{address: {4, 5, 6, 7}, x: 1.0, y: 1.0}
    }

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 0.0}
    assert %Player{address: {3, 4, 5, 6}, x: 0.0, y: 1.0} = Collisions.handle(players, shooter)

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 45.0}
    assert %Player{address: {4, 5, 6, 7}, x: 1.0, y: 1.0} = Collisions.handle(players, shooter)

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 90.0}
    assert %Player{address: {2, 3, 4, 5}, x: 1.0, y: 0.0} = Collisions.handle(players, shooter)

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 180.0}
    assert Collisions.handle(players, shooter) == nil

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 270.0}
    assert Collisions.handle(players, shooter) == nil
  end

  test "should kill only closest victim" do
    players = %{
      {2, 3, 4, 5} => %Player{address: {2, 3, 4, 5}, x: 1.0, y: 0.0},
      {3, 4, 5, 6} => %Player{address: {3, 4, 5, 6}, x: 2.0, y: 0.0},
      {4, 5, 6, 7} => %Player{address: {4, 5, 6, 7}, x: 1.0, y: 1.0}
    }

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 90.0}
    assert %Player{address: {2, 3, 4, 5}, x: 1.0, y: 0.0} = Collisions.handle(players, shooter)
  end

  test "should handle vertical angle" do
    players = %{
      # ten meters from shooter
      {2, 3, 4, 5} => %Player{address: {2, 3, 4, 5}, x: 0.00008989, y: 0.0}
    }

    shooter = %Player{x: 0, y: 0, angle: 90.0, direction: 90.0}
    assert %Player{address: {2, 3, 4, 5}, x: 0.00008989, y: 0.0} = Collisions.handle(players, shooter)

    shooter = %Player{x: 0, y: 0, angle: 91.145, direction: 90.0}
    assert %Player{address: {2, 3, 4, 5}, x: 0.00008989, y: 0.0} = Collisions.handle(players, shooter)

    # shooter = %Player{x: 0, y: 0, angle: 91.146, direction: 90.0}
    # assert Collisions.handle(players, shooter) == nil

    shooter = %Player{x: 0, y: 0, angle: 81.475, direction: 90.0}
    assert %Player{address: {2, 3, 4, 5}, x: 0.00008989, y: 0.0} = Collisions.handle(players, shooter)

    # shooter = %Player{x: 0, y: 0, angle: 81.474, direction: 90.0}
    # assert Collisions.handle(players, shooter) == nil
  end
end
