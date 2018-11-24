defmodule NischeebLazertag.Application do
  def start(_type, _args) do
    children = [
      NischeebLazertag.GenServers.Game,
      NischeebLazertag.UDPServer
    ]

    opts = [strategy: :one_for_one, name: RollCoreWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
