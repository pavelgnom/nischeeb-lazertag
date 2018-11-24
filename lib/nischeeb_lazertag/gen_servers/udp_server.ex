# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.GenServers.UDPServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, 2052, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def init(port) do
    {:ok, port} = :gen_udp.open(port, [:binary, active: true])

    {:ok, %{port: port}}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_info({:udp, _socket, address, _port, data}, state) do
    IO.puts("UDP Received: #{data}")

    with {:ok, params} <- Jason.decode(data),
         %{"action" => action, "data" => data} <- params do
      case action do
        "update_position" -> :ok = NischeebLazertag.GenServers.Game.update_position(address, data)
      end

      {:noreply, state}
    else
      {:error, _error} ->
        IO.puts("Not json")
        {:noreply, state}

      %{} ->
        IO.puts("Invalid data")
        {:noreply, state}
    end
  end
end
