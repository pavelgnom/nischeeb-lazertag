# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.GenServers.Game do
  use GenServer

  alias NischeebLazertag.GenServers.TCPPlayer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # API

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def add_player(address, data) do
    GenServer.cast(__MODULE__, {:add_player, {address, data}})
  end

  def shot(address, data) do
    GenServer.cast(__MODULE__, {:shot, {address, data}})
  end

  def update_position(address, data) do
    GenServer.cast(__MODULE__, {:update_position, {address, data}})
  end

  # SERVER

  def init(_) do
    {:ok, %{players: %{}}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_player, {address, data}}, state) do
    case NischeebLazertag.Game.add_player(data, address, state) do
      {:ok, state} ->
        json = Jason.encode!(%{action: :joined})
        TCPPlayer.send_response(address, json)
        {:noreply, state}

      {:error, :invalid_data, state} ->
        json = Jason.encode!(%{error: :invalid_data})
        TCPPlayer.send_response(address, json)
        {:noreply, state}

      {:error, :dead, _player, state} ->
        json = Jason.encode!(%{error: :dead})
        TCPPlayer.send_response(address, json)
        {:noreply, state}

      {:error, :exists, _player, state} ->
        json = Jason.encode!(%{error: :exists})
        TCPPlayer.send_response(address, json)
        {:noreply, state}
    end
  end

  def handle_cast({:shot, {address, data}}, state) do
    case NischeebLazertag.Game.shot(data, address, state) do
      {:ok, action, {shot_player, victim}, state} when action in ~w[hit killed]a ->
        if action == :killed do
          Process.send_after(__MODULE__, {:respawn, victim.address}, 30_000)
        end

        json = Jason.encode!(%{action: if(action == :hit, do: :hit, else: :kill)})
        TCPPlayer.send_response(shot_player.address, json)

        json = Jason.encode!(%{action: if(action == :hit, do: :wound, else: action), data: %{health: victim.health}})
        TCPPlayer.send_response(victim.address, json)
        {:noreply, state}

      {:ok, :miss, shot_player, state} ->
        json = Jason.encode!(%{action: :miss})
        TCPPlayer.send_response(shot_player.address, json)
        {:noreply, state}

      {:error, :dead, _player, state} ->
        {:noreply, state}

      {:error, :not_found, state} ->
        {:noreply, state}
    end
  end

  def handle_cast({:update_position, {address, data}}, state) do
    state = NischeebLazertag.Game.update_position(data, address, state)

    {:noreply, state}
  end

  def handle_info({:respawn, address}, state) do
    new_state = NischeebLazertag.Game.respawn(address, state)

    {:noreply, new_state}
  end
end
