defmodule NischeebLazertag.Gun do
  defstruct [:type, :damage]

  # @types ~w[revolver]

  def new(type) do
    case type do
      "revolver" -> %__MODULE__{type: "revolver", damage: 50}
    end
  end
end
