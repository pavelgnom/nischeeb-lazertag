defmodule NischeebLazertag.Player do
  defstruct [:address, :x, :y, :angle, :direction, :gun, :nickname, health: 100]

  alias NischeebLazertag.Gun

  def new(%{"x" => x, "y" => y} = data, address) do
    {:ok,
     %__MODULE__{
       address: address,
       x: x,
       y: y,
       nickname: data["nickname"] || "Player #{:rand.uniform(10)}",
       angle: data["angle"],
       direction: data["direction"],
       gun: Gun.new("revolver")
     }}
  end

  def update(%{"x" => x, "y" => y} = data, player) do
    {:ok, %__MODULE__{player | x: x, y: y, angle: data["angle"], direction: data["direction"]}}
  end
end
