defmodule NischeebLazertag.Player do
  defstruct [:x, :y, :angle, :direction, :gun]

  alias NischeebLazertag.Gun

  def new(%{"x" => x, "y" => y} = data) do
    {:ok, %__MODULE__{x: x, y: y, angle: data["angle"], direction: data["direction"], gun: Gun.new("revolver")}}
  end

  def new(data) do
    IO.puts("Invalid data: #{inspect(data)}")
    {:error, :invalid_data}
  end

  def update(%{"x" => x, "y" => y} = data, player) do
    {:ok, %__MODULE__{player | x: x, y: y, angle: data["angle"], direction: data["direction"]}}
  end

  def update(data, _player) do
    IO.puts("Invalid data: #{inspect(data)}")
    {:error, :invalid_data}
  end
end
