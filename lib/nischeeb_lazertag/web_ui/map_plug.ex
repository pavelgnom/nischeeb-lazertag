defmodule MapPlug do
  import Plug.Conn
  require Logger

  def init(options) do
    options
  end

  def call(conn, _opts) do
    players =
      NischeebLazertag.GenServers.Game.get_state().players
      |> Enum.map(fn {_ip, player} -> %{x: player.x, y: player.y, direction: player.direction, nickname: player.nickname} end)

    {min, max} = Enum.min_max_by(players, fn %{x: x} -> x end)
    x_scale = 500 / (max.x - min.x)

    {min, max} = Enum.min_max_by(players, fn %{y: y} -> y end)
    y_scale = 500 / (max.y - min.y)

    scaled =
      players
      |> Enum.map(fn player -> %{player | x: player.x * x_scale, y: player.y * y_scale, direction: player.direction * :math.pi() / 180} end)
      |> Jason.encode!()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, scaled)
  end
end
