# to run:
# > elixir --no-halt udp_server.exs
# to test:
# > echo "hello world" | nc -u -w0 localhost:2052
# > echo "quit" | nc -u -w0 localhost:2052

# Let's call our module "UDPServer"
defmodule NischeebLazertagBackend.UDPServer do
  # Our module is going to use the DSL (Domain Specific Language) for Gen(eric) Servers
  use GenServer

  # We need a factory method to create our server process
  # it takes a single parameter `port` which defaults to `2052`
  # This runs in the caller's context
  def start_link(_) do
    # Start 'er up
    GenServer.start_link(__MODULE__, 2052, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  def init(port) do
    # Use erlang's `gen_udp` module to open a port
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, port, address, port, data}` when new data arrives on the port
    # Returns: {:ok, port}
    {:ok, port} = :gen_udp.open(port, [:binary, active: true])

    {:ok, %{port: port, players: %{}}}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_info({:udp, _socket, address, _port, data}, state) do
    IO.puts("Received: #{String.trim(data)}")

    case Jason.decode(data) do
      {:ok, data} ->
        handle_packet(data, address, state)

      {:error, _error} ->
        IO.puts("Not json")
        {:noreply, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  defp handle_packet(%{"action" => "quit"}, _address, %{port: port} = state) do
    IO.puts("Received: quit")

    :gen_udp.close(port)

    {:stop, :normal, state}
  end

  # fallback pattern match to handle all other (non-"quit") messages
  defp handle_packet(%{"action" => "update_position", "data" => data}, address, state) do
    new_state =
      case from_map_string(data) do
        {:ok, player} -> put_in(state, [:players, address], player)
        {:error, :invalid_data} -> state
      end

    {:noreply, new_state}
  end

  defp handle_packet(data, _address, state) do
    IO.puts("Invalid data: #{inspect(data)}")

    {:noreply, state}
  end

  defp from_map_string(%{"x" => x, "y" => y, "angle" => angle, "direction" => direction}) do
    {:ok, %NischeebLazertagBackend.Player{x: x, y: y, angle: angle, direction: direction}}
  end

  defp from_map_string(data) do
    IO.puts("Invalid data: #{inspect(data)}")
    {:error, :invalid_data}
  end
end
