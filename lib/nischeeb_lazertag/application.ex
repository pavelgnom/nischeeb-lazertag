defmodule NischeebLazertag.Application do
  def start(_type, _args) do
    children = [
      NischeebLazertag.GenServers.Game,
      NischeebLazertag.UDPServer,
      {Task.Supervisor, name: NischeebLazertag.TaskSupervisor},
      {Task, fn -> NischeebLazertag.TCPServer.accept(2052) end}
    ]

    opts = [strategy: :one_for_one, name: RollCoreWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
