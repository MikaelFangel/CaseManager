defmodule CaseManagerWeb.RiskBadge do
  @moduledoc """
  Provides a badge showing risk or severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.Badge

  @doc """
  Renders a badge showing risk or severity level.

  Severity come in five level – critical, high, medium, low and info.
  This attribute is required.

  # Example

      <.risk_badge color="critical" />
      <.risk_badge color="high" />
      <.risk_badge color="medium" />
      <.risk_badge color="low" />
      <.risk_badge color="info" />
  """

  attr :color, :string, required: true, values: ["critical", "high", "medium", "low", "info"]

  attr :class, :string, default: nil
  attr :rest, :global

  def risk_badge(assigns) do
    assigns =
      assigns
      |> assign(:icon_name, icon_name(assigns))
      |> assign(:txt, txt(assigns))
      |> assign(:badge_classes, badge_classes(assigns))

    ~H"""
    <.badge
      class={@badge_classes}
      icon_name={@icon_name}
      txt={@txt}
      {@rest}
    />
    """
  end

  defp badge_classes(opts) do
    opts = %{
      color: opts[:color],
      class: opts[:class]
    }

    color_classes = color_classes(opts)
    custom_classes = opts.class

    [color_classes, custom_classes]
  end

  defp icon_name(opts) do
    opts = %{
      color: opts[:color]
    }

    get_icon_name(opts.color)
  end

  defp get_icon_name("critical"), do: "hero-exclamation-circle"
  defp get_icon_name("high"), do: "hero-arrow-up-circle"
  defp get_icon_name("medium"), do: "hero-minus-circle"
  defp get_icon_name("low"), do: "hero-arrow-down-circle"
  defp get_icon_name("info"), do: "hero-information-circle"

  defp txt(opts) do
    opts = %{
      color: opts[:color]
    }

    get_txt(opts.color)
  end

  defp get_txt("critical"), do: "Critical"
  defp get_txt("high"), do: "High"
  defp get_txt("medium"), do: "Medium"
  defp get_txt("low"), do: "Low"
  defp get_txt("info"), do: "Info"

  defp color_classes(opts) do
    opts = %{
      color: opts[:color]
    }

    get_color_classes(opts.color)
  end

  defp get_color_classes("critical"), do: "bg-red-300"
  defp get_color_classes("high"), do: "bg-orange-200"
  defp get_color_classes("medium"), do: "bg-amber-100"
  defp get_color_classes("low"), do: "bg-green-200"
  defp get_color_classes("info"), do: "bg-teal-200"
end
