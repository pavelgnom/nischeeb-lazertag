defmodule NischeebLazertag.Application do
  alias NischeebLazertag.GenServers

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: MapPlug, options: [port: 4000]),
      GenServers.Game,
      GenServers.Statistics,
      GenServers.UDPServer,
      GenServers.TCPServer
    ]

    opts = [strategy: :one_for_one, name: RollCoreWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
