defmodule NischeebLazertag.GenServers.Statistics do
  @derive [Jason.Encoder]
  defstruct shots: 0, hits: 0, kills: 0, deaths: 0

  use GenServer

  require Logger

  alias NischeebLazertag.GenServers.TCPPlayer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # API

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def add(player) do
    GenServer.cast(__MODULE__, {:add, player})
  end

  def get_statistics(address) do
    GenServer.cast(__MODULE__, {:get_statistics, address})
  end

  def update(data) do
    GenServer.cast(__MODULE__, {:update, data})
  end

  # SERVER

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add, player}, state) do
    player_statistics = find_statistics(player, state)

    new_state = Map.put(state, player.address, player_statistics)

    {:noreply, new_state}
  end

  def handle_cast({:update, data}, state) do
    new_state =
      case data do
        %{action: :hit, shot_player: shot_player, victim: _victim} ->
          shot_player_statistics = find_statistics(shot_player, state)

          shot_player_statistics = %{shot_player_statistics | shots: shot_player_statistics.shots + 1, hits: shot_player_statistics.hits + 1}

          Map.put(state, shot_player.address, shot_player_statistics)

        %{action: :killed, shot_player: shot_player, victim: victim} ->
          shot_player_statistics = find_statistics(shot_player, state)
          victim_statistics = find_statistics(victim, state)

          shot_player_statistics = %{
            shot_player_statistics
            | shots: shot_player_statistics.shots + 1,
              hits: shot_player_statistics.hits + 1,
              kills: shot_player_statistics.kills + 1
          }

          victim_statistics = %{victim_statistics | deaths: victim_statistics.deaths + 1}

          state
          |> Map.put(shot_player.address, shot_player_statistics)
          |> Map.put(victim.address, victim_statistics)

        %{action: :miss, shot_player: shot_player} ->
          shot_player_statistics = find_statistics(shot_player, state)

          shot_player_statistics = %{shot_player_statistics | shots: shot_player_statistics.shots + 1}

          Map.put(state, shot_player.address, shot_player_statistics)
      end

    {:noreply, new_state}
  end

  def handle_cast({:get_statistics, address}, state) do
    statistics = find_statistics(%NischeebLazertag.Player{address: address}, state)

    json = Jason.encode!(statistics)
    TCPPlayer.send_response(address, json)

    {:noreply, state}
  end

  defp find_statistics(player, state) do
    case Enum.find(state, fn {ip, _statistic} -> ip == player.address end) do
      {_ip, statistics} -> statistics
      nil -> %__MODULE__{}
    end
  end
end
