defmodule CaseManagerWeb.AlertGenerator do
  @moduledoc """
  Generator for alert data that can be used in tests. The generator generates valid alert data.
  """
  use ExUnitProperties

  @doc """
  Gives a list of valid risk levels. The given risk levels are ordered by their severity
  and is static.
  """
  def valid_risk_levels, do: [:info, :low, :medium, :high, :critical]

  @doc """
  A generator for risk levels. The generator generates a random risk level from 
  the list of valid risk levels.
  """
  def risk_level, do: StreamData.member_of(valid_risk_levels())

  @doc """
  A generator for alert attributes. The generator generates a map with the following keys:
  alert_id, title, risk_level, start_time, end_time, link. The values for the keys are generated
  randomly.
  """
  def alert_attrs do
    gen all(
          alert_id <- StreamData.string(:alphanumeric, length: 8),
          title <- StreamData.string(:printable, min_length: 1),
          risk_level <- risk_level(),
          start_time <- StreamData.constant(DateTime.utc_now() |> DateTime.to_iso8601()),
          end_time <-
            StreamData.constant(DateTime.utc_now() |> DateTime.add(3600) |> DateTime.to_iso8601()),
          link <- StreamData.string(:printable, min_length: 1)
        ) do
      %{
        alert_id: alert_id,
        title: title,
        risk_level: risk_level,
        start_time: start_time,
        end_time: end_time,
        link: link
      }
    end
  end
end
