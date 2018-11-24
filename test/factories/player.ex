defmodule NischeebLazertag.Factories.Player do
  use ExMachina

  alias NischeebLazertag.Player

  def player_factory do
    %Player{
      address: {127, 0, 0, 1},
      x: 0,
      y: 0,
      angle: 0,
      direction: 0,
      gun: NischeebLazertag.Factories.Gun.build(:gun)
    }
  end
end
