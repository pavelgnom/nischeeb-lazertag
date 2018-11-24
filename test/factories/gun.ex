defmodule NischeebLazertag.Factories.Gun do
  use ExMachina

  alias NischeebLazertag.Gun

  def gun_factory do
    %Gun{
      type: "revolver",
      damage: 50
    }
  end
end
