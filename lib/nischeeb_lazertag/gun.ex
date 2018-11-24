defmodule NischeebLazertag.Gun do
  defstruct [:type, :ammo, :damage]

  # @types ~w[revolver]

  def new(type) do
    case type do
      "revolver" ->
        %__MODULE__{type: "revolver", ammo: 6, damage: 100}
    end
  end
end
