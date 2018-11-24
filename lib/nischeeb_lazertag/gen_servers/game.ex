# > echo "hello world" | nc -u -w0 localhost:2052
defmodule NischeebLazertag.GenServers.Game do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # API
  def add_player(address, data) do
    GenServer.call(__MODULE__, {:add_player, {address, data}})
  end

  def shot(address, data) do
    GenServer.call(__MODULE__, {:shot, {address, data}})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def update_position(address, data) do
    GenServer.cast(__MODULE__, {:update_position, {address, data}})
  end

  # SERVER

  def init(_) do
    {:ok, %{players: %{}}}
  end

  def handle_call({:add_player, {address, data}}, _from, state) do
    case NischeebLazertag.Game.add_player(data, address, state) do
      {:ok, state} ->
        {:reply, :ok, state}

      {:error, :invalid_data, state} ->
        {:reply, {:error, :invalid_data}, state}

      {:error, :dead, player, state} ->
        {:reply, {:error, :dead, player}, state}

      {:error, :exists, player, state} ->
        {:reply, {:error, :exists, player}, state}
    end
  end

  def handle_call({:shot, {address, data}}, _from, state) do
    case NischeebLazertag.Game.shot(data, address, state) do
      {:ok, :hit, {shot_player, victim}, state} ->
        {:reply, {:ok, :hit, [shot_player, victim]}, state}

      {:ok, :miss, shot_player, state} ->
        {:reply, {:ok, :miss, [shot_player]}, state}

      {:error, :dead, player, state} ->
        {:reply, {:error, :dead, player}, state}

      {:error, :not_found, state} ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:update_position, {address, data}}, state) do
    state = NischeebLazertag.Game.update_position(data, address, state)

    {:noreply, state}
  end
end
