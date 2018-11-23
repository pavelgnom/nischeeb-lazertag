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

    {:ok, %{port: port, user_positions: %{}}}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_info({:udp, _socket, address, _port, data}, state) do
    # punt the data to a new function that will do pattern matching

    handle_packet(data, address, state)
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  def handle_call(:get_state, _from, state) do
    # punt the data to a new function that will do pattern matching

    {:reply, state, state}
  end

  # pattern match the "quit" message
  defp handle_packet("quit\n", _, port) do
    IO.puts("Received: quit111")

    # close the port
    :gen_udp.close(port)

    # GenServer will understand this to mean we want to stop the server
    # action: :stop
    # reason: :normal
    # new_state: nil, it doesn't matter since we're shutting down :(
    {:stop, :normal, nil}
  end

  # fallback pattern match to handle all other (non-"quit") messages
  defp handle_packet(data, address, state) do
    IO.puts("Received: #{String.trim(data)}")
    data = Jason.decode!(data)
    new_state = put_in(state, [:user_positions, address], data)
    {:noreply, new_state}
  end
end
