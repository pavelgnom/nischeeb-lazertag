defmodule NischeebLazertag.Utils.Calculations do
  @earth_radius_in_meters 6_378_137

  alias NischeebLazertag.Utils.Vector

  def point_on_line(any_point_on_line, line_direction, point) do
    Vector.add(any_point_on_line, Vector.multiply(line_direction, Vector.dot_product(line_direction, Vector.sub(point, any_point_on_line))))
  end

  def earth_distance(a, b) do
    lat_a = degrees_to_radians(a.y)
    lat_b = degrees_to_radians(b.y)

    lon_a = degrees_to_radians(a.x)
    lon_b = degrees_to_radians(b.x)

    lat_sin_a = :math.sin(lat_a)
    lat_sin_b = :math.sin(lat_b)
    lat_cos_a = :math.cos(lat_a)
    lat_cos_b = :math.cos(lat_b)

    lon_delta = lon_b - lon_a
    delta_cos = :math.cos(lon_delta)
    delta_sin = :math.sin(lon_delta)

    mult1 = lat_cos_a * delta_sin
    mult2 = lat_cos_a * lat_sin_b - lat_sin_a * lat_cos_b * delta_cos

    y = :math.sqrt(mult1 * mult1 + mult2 * mult2)
    x = lat_sin_a * lat_sin_b + lat_cos_a * lat_cos_b * delta_cos
    angle = :math.atan(y / x)

    angle =
      if angle < 0 do
        angle + :math.pi()
      else
        angle
      end

    angle * @earth_radius_in_meters
  end

  def get_max_hit_angle(distance, object_height) do
    radians_to_degrees(:math.atan(object_height / distance))
  end

  def degrees_to_radians(degrees) do
    :math.pi() * degrees / 180.0
  end

  def radians_to_degrees(radians) do
    180.0 * radians / :math.pi()
  end
end
