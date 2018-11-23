defmodule NischeebLazertagBackend.Collisions do
  @epsilon 0.5
  def handle(potential_victims, shooter) do
    angle = :math.pi() * shooter.direction / 180.0

    vector = %{
      p1: %{x: shooter.x, y: shooter.y},
      p2: %{x: :math.cos(angle), y: :math.sin(angle)}
    }

    Enum.map(potential_victims, fn victim ->
      distance =
        Kernel.abs(
          (vector[:p2][:y] - vector[:p1][:y]) * victim.x -
            (vector[:p2][:x] - vector[:p1][:x]) * victim.y + vector[:p2][:x] * vector[:p1][:y] -
            vector[:p2][:y] * vector[:p1][:x]
        ) /
          :math.sqrt(
            :math.pow(vector[:p2][:y] - vector[:p1][:y], 2) +
              :math.pow(vector[:p2][:x] - vector[:p1][:x], 2)
          )

      distance_from_shooter =
        :math.sqrt(:math.pow(shooter.x - victim.x, 2) + :math.pow(shooter.y - victim.y, 2))

      %{victim: victim, hit: distance < @epsilon, distance: distance_from_shooter}
    end)
    |> Enum.sort_by(fn hit -> hit.distance end)
    |> Enum.find(& &1.hit)
    |> Map.get(:victim)
  end
end
