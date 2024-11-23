defmodule CaseManagerWeb.RiskBadge do
  @moduledoc """
  Provides a badge showing risk or severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.BadgeTemplate
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a badge showing risk or severity level.

  Severity come in five level – critical, high, medium, low and info.
  This attribute is required.

  # Example

      <.risk_badge colour={:critical} />
      <.risk_badge colour={:high} />
      <.risk_badge colour={:medium} />
      <.risk_badge colour={:low} />
      <.risk_badge colour={:info} />

  """
  attr :colour, :atom, required: true, values: [:critical, :high, :medium, :low, :info]

  attr :class, :string, default: nil
  attr :rest, :global

  def risk_badge(assigns) do
    assigns =
      assigns
      |> assign(:icon_name, icon_name(assigns))
      |> assign(:label, label(assigns))
      |> assign(:badge_class, badge_class(assigns))

    ~H"""
    <.badge_template class={@badge_class} icon_name={@icon_name} label={@label} {@rest} />
    """
  end

  defp icon_name(%{colour: :critical}), do: "hero-exclamation-circle"
  defp icon_name(%{colour: :high}), do: "hero-arrow-up-circle"
  defp icon_name(%{colour: :medium}), do: "hero-minus-circle"
  defp icon_name(%{colour: :low}), do: "hero-arrow-down-circle"
  defp icon_name(%{colour: :info}), do: "hero-information-circle"

  defp label(%{colour: :critical}), do: gettext("Critical")
  defp label(%{colour: :high}), do: gettext("High")
  defp label(%{colour: :medium}), do: gettext("Medium")
  defp label(%{colour: :low}), do: gettext("Low")
  defp label(%{colour: :info}), do: gettext("Info")

  defp badge_class(%{colour: colour, class: class}), do: [colour_class(colour), class]
  defp badge_class(%{colour: colour}), do: colour_class(colour)

  defp colour_class(:critical), do: "bg-red-300"
  defp colour_class(:high), do: "bg-orange-200"
  defp colour_class(:medium), do: "bg-amber-100"
  defp colour_class(:low), do: "bg-green-200"
  defp colour_class(:info), do: "bg-teal-200"
end
