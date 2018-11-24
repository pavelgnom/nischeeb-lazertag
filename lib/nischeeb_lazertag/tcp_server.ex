defmodule NischeebLazertag.TCPServer do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    send(__MODULE__, :start)
    {:ok, clients: []}
  end

  def handle_info(:start, state) do
    {:ok, socket} = :gen_tcp.listen(2052, [:binary, packet: :line, active: false, reuseaddr: true])
    {:ok, client} = :gen_tcp.accept(socket)
    {:noreply, %{}}
  end

  def handle_info({:tcp, socket, data}, state) do
    require IEx
    IEx.pry()
    {:ok, {ip, client_port}} = :inet.peername(socket)
    {:ok, pid} = TCPPlayer.start_link(socket, ip)
    :ok = :gen_tcp.controlling_process(socket, pid)
    {:noreply, state}
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  def send_response(ip, data) do
    NischeebLazertag.TaskSupervisor
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, {ip, _client_port}} = :inet.peername(client)
    {:ok, pid} = Task.Supervisor.start_child(NischeebLazertag.TaskSupervisor, fn -> serve(client) end, name: {:global, ip})
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case read_line(socket) do
      :closed ->
        Logger.info("Connection closed")

      data ->
        {:ok, {ip, client_port}} = :inet.peername(socket)

        require IEx
        IEx.pry()

        # case decode(data) do
        #   %{"action" => "join"} = data ->
        #     NischeebLazertag.GenServers.Game.add_player(ip, data)
        # end

        write_line(data, socket)
        serve(socket)
    end
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.puts(data)
        data

      {:error, _reason} ->
        :gen_tcp.close(socket)
        :closed
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  # {"action": "join", "data": {"x": "0", "y": "0"}}
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
