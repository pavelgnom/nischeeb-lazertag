# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.UDPServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, 2052, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def init(port) do
    {:ok, port} = :gen_udp.open(port, [:binary, active: true])

    {:ok, %{port: port, players: %{}}}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_info({:udp, _socket, address, _port, data}, state) do
    IO.puts("Received: #{String.trim(data)}")

    case Jason.decode(data) do
      {:ok, data} ->
        NischeebLazertag.Game.handle_packet(data, address, state)

      {:error, _error} ->
        IO.puts("Not json")
        {:noreply, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
