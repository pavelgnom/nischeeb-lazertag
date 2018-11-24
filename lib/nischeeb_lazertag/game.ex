defmodule NischeebLazertag.Game do
  alias NischeebLazertag.Player

  def handle_packet(%{"action" => "join", "data" => data}, address, state) do
    with {:error, :player_not_found} <- find_player(address, state),
         {:ok, player} <- Player.new(data, address) do
      put_in(state, [:players, address], player)
    else
      {:error, :invalid_data} ->
        state

      {:error, :dead} ->
        IO.puts("Player is dead")
        state

      {:ok, _player} ->
        IO.puts("Player already exists")
        state
    end
  end

  def handle_packet(%{"action" => "update_position", "data" => data}, address, state) do
    require IEx

    with {:ok, player} <- find_player(address, state),
         IEx.pry(),
         {:ok, player} <- Player.update(data, player) do
      put_in(state, [:players, address], player)
    else
      {:error, :invalid_data} ->
        state

      {:error, :player_not_found} ->
        IO.puts("Player not found")
        state

      {:error, :dead} ->
        IO.puts("Player is dead")
        state
    end
  end

  def handle_packet(%{"action" => "shot", "data" => data}, address, state) do
    with {:ok, shot_player} <- find_player(address, state),
         {:ok, shot_player} <- Player.update(data, shot_player) do
      new_state = put_in(state, [:players, address], shot_player)
      players = Map.delete(state.players, address)

      victim = NischeebLazertag.Collisions.handle(players, shot_player)

      if victim do
        damage = shot_player.gun.damage
        health_after_shot = victim.health - damage

        victim =
          if health_after_shot > 0 do
            %{victim | health: health_after_shot}
          else
            %{victim | health: 0}
          end

        put_in(state, [:players, victim.address], victim)
      else
        new_state
      end
    else
      {:error, :invalid_data} ->
        IO.puts("Invalid data")
        state

      {:error, :player_not_found} ->
        IO.puts("Player not found")
        state

      {:error, :dead} ->
        IO.puts("Player is dead")
        state
    end
  end

  def handle_packet(%{"action" => "quit"}, _address, %{port: port} = state) do
    IO.puts("Received: quit")

    :gen_udp.close(port)

    {:stop, :normal, state}
  end

  def handle_packet(data, _address, state) do
    IO.puts("Invalid data: #{inspect(data)}")
    state
  end

  defp find_player(address, state) do
    data = Enum.find(state.players, fn {addr, _player} -> addr == address end)

    case data do
      nil -> {:error, :player_not_found}
      {_address, %Player{health: 0}} -> {:error, :dead}
      {_address, %Player{} = player} -> {:ok, player}
    end
  end
end
