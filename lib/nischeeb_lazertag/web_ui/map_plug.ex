defmodule MapPlug do
  import Plug.Conn
  require Logger

  def init(options) do
    options
  end

  def call(conn, _opts) do
    if conn.request_path == "/" do
      file = File.read!(File.cwd!() <> "/lib/nischeeb_lazertag/web_ui/index.html")

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, file)
    else
      players =
        NischeebLazertag.GenServers.Game.get_state().players
        |> Enum.map(fn {_ip, player} ->
          %{x: player.x, y: -player.y, direction: player.direction, nickname: player.nickname, health: player.health}
        end)

      # players = [%{direction: 225, nickname: "90", x: 30, y: -30, health: 100}, %{direction: 20, nickname: "0", x: 0, y: 0, health: 100}]

      {x_min, x_max} = Enum.min_max_by(players, fn %{x: x} -> x end, fn -> {0, 500} end)
      x_delta = x_max.x - x_min.x

      {y_min, y_max} = Enum.min_max_by(players, fn %{y: y} -> y end, fn -> {0, 500} end)
      y_delta = y_max.y - y_min.y

      scale = 650 / Enum.max([x_delta, y_delta])

      scaled =
        players
        |> Enum.map(fn player -> %{player | x: player.x * scale, y: player.y * scale, direction: player.direction * :math.pi() / 180} end)
        |> Jason.encode!()

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, scaled)
    end
  end
end
