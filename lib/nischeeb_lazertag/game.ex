defmodule NischeebLazertag.Game do
  alias NischeebLazertag.Player

  def handle_packet(%{"action" => "join", "data" => data}, address, state) do
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

  def handle_packet(%{"action" => "update_position", "data" => data}, address, state) do
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

  def handle_packet(%{"action" => "shot", "data" => data}, address, state) do
    new_state =
      with {:ok, player} <- find_player(address, state),
           {:ok, player} <- Player.update(data, player) do
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

  def handle_packet(%{"action" => "quit"}, _address, %{port: port} = state) do
    IO.puts("Received: quit")

    :gen_udp.close(port)

    {:stop, :normal, state}
  end

  def handle_packet(data, _address, state) do
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
end
