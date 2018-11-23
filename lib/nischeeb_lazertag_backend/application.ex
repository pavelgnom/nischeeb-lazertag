defmodule NischeebLazertagBackend.Application do
  def start(_type, _args) do
    children = [
      NischeebLazertagBackend.UDPServer
    ]

    opts = [strategy: :one_for_one, name: RollCoreWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
