defmodule NischeebLazertagBackend.CollisionsTest do
  use ExUnit.Case

  alias NischeebLazertagBackend.{Player, Collisions}

  test "should handle collisions" do
    players = [
      %Player{ip: {1, 2, 3, 4}, x: 0.0, y: 0.0},
      %Player{ip: {2, 3, 4, 5}, x: 1.0, y: 0.0},
      %Player{ip: {3, 4, 5, 6}, x: 0.0, y: 1.0},
      %Player{ip: {4, 5, 6, 7}, x: 1.0, y: 1.0}
    ]

    shooter = %Player{ip: {1, 2, 3, 4}, x: 0, y: 0, angle: 0.0, direction: 90.0}

    assert Collisions.handle(players, shooter) == %Player{ip: {3, 4, 5, 6}, x: 0.0, y: 1.0}
  end
end
