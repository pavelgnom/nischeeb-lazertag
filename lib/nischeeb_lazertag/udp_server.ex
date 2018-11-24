# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.UDPServer do
  use GenServer

  alias NischeebLazertag.{Gun, Player}

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
        handle_packet(data, address, state)

      {:error, _error} ->
        IO.puts("Not json")
        {:noreply, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  defp handle_packet(%{"action" => "join", "data" => data}, address, state) do
    new_state =
      with {:error, :player_not_found} <- find_player(address, state),
           {:ok, player} <- Player.new(data) do
        put_in(state, [:players, address], player)
      else
        {:error, :invalid_data} ->
          state

        {:ok, _player} ->
          IO.puts("Player already exists")
          state
      end

    {:noreply, new_state}
  end

  defp handle_packet(%{"action" => "update_position", "data" => data}, address, state) do
    new_state =
      with {:ok, player} <- find_player(address, state),
           {:ok, player} <- Player.update(data, player) do
        put_in(state, [:players, address], player)
      else
        {:error, :invalid_data} ->
          state

        {:error, :player_not_found} ->
          IO.puts("Player not found")
          state
      end

    {:noreply, new_state}
  end

  defp handle_packet(%{"action" => "shot", "data" => data}, address, state) do
    new_state =
      with {:ok, player} <- find_player(address, state),
           {:ok, player} <- Player.update(data, player),
           {:ok, player} <- decrement_ammo(player) do
        new_state = put_in(state, [:players, address], player)
        players = Map.delete(state.players, address)

        NischeebLazertag.Collisions.handle(players, player)

        new_state
      else
        {:error, :invalid_data} ->
          IO.puts("Invalid data")
          state

        {:error, :player_not_found} ->
          IO.puts("Player not found")
          state

        {:error, :zero_ammo} ->
          IO.puts("Zero ammo")
          state
      end

    {:noreply, new_state}
  end

  defp handle_packet(%{"action" => "quit"}, _address, %{port: port} = state) do
    IO.puts("Received: quit")

    :gen_udp.close(port)

    {:stop, :normal, state}
  end

  defp handle_packet(data, _address, state) do
    IO.puts("Invalid data: #{inspect(data)}")

    {:noreply, state}
  end

  defp find_player(address, state) do
    data = Enum.find(state.players, fn {addr, _player} -> addr == address end)

    case data do
      nil -> {:error, :player_not_found}
      {_address, player} -> {:ok, player}
    end
  end

  defp decrement_ammo(player) do
    case player.gun do
      %Gun{ammo: ammo} = gun when ammo > 0 ->
        gun = %{gun | ammo: ammo - 1}
        player = %{player | gun: gun}
        {:ok, player}

      _ ->
        {:error, :zero_ammo}
    end
  end
end
