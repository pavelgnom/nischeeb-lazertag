defmodule MapPlug do
  import Plug.Conn
  require Logger

  def init(options) do
    options
  end

  def call(conn, _opts) do
    players =
      NischeebLazertag.GenServers.Game.get_state().players
      |> Enum.map(fn {_ip, player} -> %{x: player.x, y: player.y, direction: player.direction, nickname: player.nickname, health: player.health} end)

    {x_min, x_max} = Enum.min_max_by(players, fn %{x: x} -> x end, fn -> {0, 500} end)
    x_delta = x_max.x - x_min.x

    {y_min, y_max} = Enum.min_max_by(players, fn %{y: y} -> y end, fn -> {0, 500} end)
    y_delta = y_max.y - y_min.y

    scale = 500 / Enum.max([x_delta, y_delta])

    scaled =
      players
      |> Enum.map(fn player -> %{player | x: player.x * scale, y: player.y * scale, direction: player.direction * :math.pi() / 180} end)
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, scaled)
  end
end
