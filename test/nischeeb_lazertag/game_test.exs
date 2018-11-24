defmodule NischeebLazertag.GameTest do
  use ExUnit.Case

  alias NischeebLazertag.{Factories, Game, Player, Gun}

  describe "handle packet" do
    test "with action join" do
      data = %{"x" => 10.1, "y" => 10.2, "angle" => 120, "direction" => 110}
      response = Game.handle_packet(%{"action" => "join", "data" => data}, {127, 0, 0, 10}, %{players: %{}})
      assert %{{127, 0, 0, 10} => %Player{x: 10.1, y: 10.2, angle: 120, direction: 110, gun: %Gun{type: "revolver"}}} = response.players
    end

    test "with action update_position" do
      player = Factories.Player.build(:player, address: {127, 0, 0, 1})
      data = %{"x" => 10.1, "y" => 10.2, "angle" => 110, "direction" => 90}
      response = Game.handle_packet(%{"action" => "update_position", "data" => data}, {127, 0, 0, 1}, %{players: %{{127, 0, 0, 1} => player}})
      assert %{{127, 0, 0, 1} => %Player{x: 10.1, y: 10.2, angle: 110, direction: 90, gun: %Gun{type: "revolver"}}} = response.players
    end

    test "with action shot" do
      player1 = Factories.Player.build(:player, address: {127, 0, 0, 1})
      player2 = Factories.Player.build(:player, address: {127, 0, 0, 2})

      data = %{"x" => 10.1, "y" => 10.2, "angle" => 110, "direction" => 90}

      response =
        Game.handle_packet(%{"action" => "shot", "data" => data}, {127, 0, 0, 1}, %{players: %{{127, 0, 0, 1} => player1, {127, 0, 0, 2} => player2}})

      assert %{{127, 0, 0, 1} => %Player{x: 10.1, y: 10.2, angle: 110, direction: 90, gun: %Gun{type: "revolver"}}} = response.players
    end
  end
end
