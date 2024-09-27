defmodule CaseManagerWeb.AlertGenerator do
  use ExUnitProperties

  def valid_risk_levels, do: ["Informational", "Low", "Medium", "High", "Critical"]

  def risk_level, do: StreamData.member_of(valid_risk_levels())

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
