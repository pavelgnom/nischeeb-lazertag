# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.GenServers.TCPPlayer do
  use GenServer

  def start_link(socket, ip) do
    GenServer.start_link(__MODULE__, socket, name: {:global, ip})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def send_response(address, json) do
    GenServer.cast({:global, address}, {:send_response, json})
  end

  # SERVER

  def init(socket) do
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, socket, data}, state) do
    {:ok, {ip, _client_port}} = :inet.peername(socket)

    IO.puts("Received: #{data}")

    case decode(data) do
      %{"action" => "join", "data" => data} ->
        NischeebLazertag.GenServers.Game.add_player(ip, data)

      %{"action" => "shot", "data" => data} ->
        NischeebLazertag.GenServers.Game.shot(ip, data)

      %{"action" => "join"} ->
        NischeebLazertag.GenServers.Game.add_player(ip, %{"x" => 0, "y" => 0})

      _ ->
        42
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    # {:ok, {ip, _client_port}} = :inet.peername(socket)
    :gen_tcp.close(socket)
    IO.puts("TCP connection closed ip: unknown")
    {:stop, :normal, state}
  end

  def handle_cast({:send_response, json}, state) do
    :gen_tcp.send(state.socket, json)

    {:noreply, state}
  end

  defp decode(data) do
    with {:ok, data} <- Jason.decode(data) do
      data
    else
      {:error, _error} ->
        IO.puts("Not json")

      %{} ->
        IO.puts("Invalid data")
    end
  end
end
