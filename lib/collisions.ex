defmodule NischeebLazertag.Collisions do
  @heigth_of_gun 1.5
  @height_of_human 1.7
  @height_above_gun @height_of_human - @heigth_of_gun
  @epsilon 3.0

  alias NischeebLazertag.Utils.{Vector, Calculations}
  require Logger

  def handle(potential_victims, shooter) do
    vertical_angle = shooter.angle - 90
    # angle = convert_angle(shooter.direction)
    # angle = :math.pi() * shooter.direction / 180.0

    angle = :math.pi() * shooter.direction / 180.0

    IO.puts(angle)

    vector = %{
      p1: %{x: shooter.x, y: shooter.y},
      p2: %{x: :math.cos(angle), y: :math.sin(angle)}
    }

    shooter_location = %Vector{x: shooter.x, y: shooter.y}
    shot_direction = %Vector{x: vector[:p2][:x], y: vector[:p2][:y]}

    # shot_direction

    Enum.map(potential_victims, fn {_ip, victim} ->
      victim_location = %Vector{x: victim.x, y: victim.y}

      # IO.puts(inspect(shot_direction))
      # IO.puts(inspect(Vector.normalize(Vector.sub(victim_location, shooter_location))))

      dot_product = Vector.dot_product(shot_direction, Vector.sub(victim_location, shooter_location))
      IO.puts(inspect(dot_product))

      if dot_product > 0 do
        point_on_shot_line = Calculations.point_on_line(shooter_location, shot_direction, victim_location)
        distance_to_shot_line = Calculations.earth_distance(victim_location, point_on_shot_line)
        distance_from_shooter = Calculations.earth_distance(victim_location, shooter_location)

        if distance_to_shot_line < @epsilon do
          {vertical_hit, hit_angle} =
            if vertical_angle >= 0 do
              angle = Calculations.get_max_hit_angle(distance_from_shooter, @height_above_gun)
              # {vertical_angle < angle, angle}
              {true, angle}
            else
              angle = Calculations.get_max_hit_angle(distance_from_shooter, @heigth_of_gun)
              # {vertical_angle > -angle, angle}
              {true, angle}
            end

          if vertical_hit do
            Logger.info("Vertical HIT",
              distance: distance_from_shooter,
              dot_product: dot_product,
              victim: inspect(victim),
              shot_player: inspect(shooter),
              angle: vertical_angle,
              hit_angle: hit_angle
            )
          else
            Logger.info("Vertical MISS",
              distance: distance_from_shooter,
              dot_product: dot_product,
              victim: inspect(victim),
              shot_player: inspect(shooter),
              angle: vertical_angle,
              hit_angle: hit_angle
            )
          end

          %{victim: victim, hit: vertical_hit, distance: distance_from_shooter, dot_product: dot_product}
        else
          Logger.info("Horisontal MISS",
            distance: distance_from_shooter,
            dot_product: dot_product,
            victim: inspect(victim),
            shot_player: inspect(shooter)
          )

          %{victim: victim, hit: false, distance: distance_from_shooter, dot_product: dot_product}
        end
      else
        Logger.info("Dot product is negative", dot_product: dot_product, victim: inspect(victim), shot_player: inspect(shooter))
        %{victim: victim, hit: false, distance: 0, dot_product: dot_product}
      end
    end)
    |> Enum.sort_by(fn hit -> hit.distance end)
    |> Enum.find(%{}, fn victim -> victim.hit && victim.dot_product > 0 end)
    |> Map.get(:victim)
  end

  def convert_angle(mobile_angle) do
    # cond do
    # end
    42
  end
end
