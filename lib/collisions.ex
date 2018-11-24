defmodule NischeebLazertag.Collisions do
  @epsilon 1.0

  alias NischeebLazertag.Utils.{Vector, Calculations}

  def handle(potential_victims, shooter) do
    angle = -:math.pi() * (shooter.direction - 90) / 180.0

    vector = %{
      p1: %{x: shooter.x, y: shooter.y},
      p2: %{x: :math.cos(angle), y: :math.sin(angle)}
    }

    shooter_location = %Vector{x: shooter.x, y: shooter.y}
    shot_direction = %Vector{x: vector[:p2][:x], y: vector[:p2][:y]}

    # shot_direction

    Enum.map(potential_victims, fn {ip, victim} ->
      victim_location = %Vector{x: victim.x, y: victim.y}

      dot_product = Vector.dot_product(shot_direction, victim_location)

      if dot_product > 0 do
        point_on_shot_line = Calculations.point_on_line(shooter_location, shot_direction, victim_location)
        distance_to_shot_line = Calculations.earth_distance(victim_location, point_on_shot_line)
        distance_from_shooter = Calculations.earth_distance(victim_location, shooter_location)
        %{victim: ip, hit: distance_to_shot_line < @epsilon, distance: distance_from_shooter, dot_product: dot_product}
      else
        %{victim: ip, hit: false, distance: 0, dot_product: dot_product}
      end
    end)
    |> Enum.sort_by(fn hit -> hit.distance end)
    |> Enum.find(%{}, fn victim -> victim.hit && victim.dot_product > 0 end)
    |> Map.get(:victim)
  end
end
