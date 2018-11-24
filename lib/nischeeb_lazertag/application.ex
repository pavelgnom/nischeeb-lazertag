defmodule NischeebLazertag.Application do
  alias NischeebLazertag.GenServers

  def start(_type, _args) do
    children = [
      GenServers.Game,
      GenServers.Statistics,
      GenServers.UDPServer,
      GenServers.TCPServer
    ]

    opts = [strategy: :one_for_one, name: RollCoreWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
