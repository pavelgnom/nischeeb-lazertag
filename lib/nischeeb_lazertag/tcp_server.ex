defmodule NischeebLazertag.TCPServer do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, clients: []}
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(NischeebLazertag.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case read_line(socket) do
      :closed ->
        Logger.info("Connection closed")

      data ->
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
end
