# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.TCPPlayer do
  use GenServer

  def start_link(socket, ip) do
    GenServer.start_link(__MODULE__, socket, name: {:global, ip})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def sent_response(address, json) do
    GenServer.cast({:global, address}, {:sent_response, json})
  end

  # SERVER

  def init(socket) do
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, socket, params}, state) do
    # {:ok, {ip, client_port}} = :inet.peername(socket)

    case decode(params) do
      %{"action" => "join", "data" => data} = params ->
        NischeebLazertag.GenServers.Game.add_player(ip, data)
    end

    {:noreply, state}
  end

  def handle_cast({:sent_response, json}, state) do
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

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
