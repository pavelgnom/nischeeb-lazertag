defmodule NischeebLazertag.Utils.Vector do
  defstruct x: 0.0, y: 0.0, z: 0.0

  alias NischeebLazertag.Utils.Vector

  def add(a, b) do
    %Vector{x: a.x + b.x, y: a.y + b.y, z: a.z + b.z}
  end

  @spec sub(atom() | %{x: number(), y: number(), z: number()}, atom() | %{x: number(), y: number(), z: number()}) :: NischeebLazertag.Vector.t()
  def sub(a, b) do
    %Vector{x: a.x - b.x, y: a.y - b.y, z: a.z - b.z}
  end

  def multiply(vector, scalar) do
    %Vector{x: vector.x * scalar, y: vector.y * scalar, z: vector.z * scalar}
  end

  def dot_product(a, b) do
    a.x * b.x + a.y * b.y + a.z * b.z
  end

  def normalize(vector) do
    length = vector_length(vector)
    %Vector{x: vector.x / length, y: vector.y / length, z: vector.z / length}
  end

  def vector_length(vector) do
    :math.sqrt(:math.pow(vector.x, 2) + :math.pow(vector.y, 2) + :math.pow(vector.z, 2))
  end
end
