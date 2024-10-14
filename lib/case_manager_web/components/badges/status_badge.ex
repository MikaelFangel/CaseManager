defmodule CaseManagerWeb.StatusBadge do
  @moduledoc """
  Provides a badge showing risk or severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.BadgeTemplate
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a badge showing a status.

  Status come in five categories – tpos (true-positive), benign, pend (pending), fpos (false-positive) and inprog (in progress).
  This attribute is required.

  # Example

      <.status_badge colour={:t_positive} />
      <.status_badge colour={:benign} />
      <.status_badge colour={:pending} />
      <.status_badge colour={:f_positive} />
      <.status_badge colour={:in_progress} />

  """
  attr :colour, :atom,
    required: true,
    values: [:t_positive, :benign, :pending, :f_positive, :in_progress]

  attr :class, :string, default: nil
  attr :rest, :global

  def status_badge(assigns) do
    assigns =
      assigns
      |> assign(:icon_name, icon_name(assigns))
      |> assign(:label, label(assigns))
      |> assign(:badge_class, badge_class(assigns))

    ~H"""
    <.badge_template class={@badge_class} icon_name={@icon_name} txt={@label} {@rest} />
    """
  end

  defp icon_name(%{colour: :t_positive}), do: "hero-fire"
  defp icon_name(%{colour: :benign}), do: "hero-check-circle"
  defp icon_name(%{colour: :pending}), do: "hero-clock"
  defp icon_name(%{colour: :f_positive}), do: "hero-x-circle"
  defp icon_name(%{colour: :in_progress}), do: "hero-bolt"

  defp label(%{colour: :t_positive}), do: gettext("T. Positive")
  defp label(%{colour: :benign}), do: gettext("Benign")
  defp label(%{colour: :pending}), do: gettext("Pending")
  defp label(%{colour: :f_positive}), do: gettext("F. Positive")
  defp label(%{colour: :in_progress}), do: gettext("In Progress")

  defp badge_class(%{colour: colour, class: class}), do: [colour_class(colour), class]
  defp badge_class(%{colour: colour}), do: colour_class(colour)

  defp colour_class(:t_positive), do: "bg-red-300"
  defp colour_class(:benign), do: "bg-green-200"
  defp colour_class(:pending), do: "bg-amber-100"
  defp colour_class(:f_positive), do: "bg-gray-300"
  defp colour_class(:in_progress), do: "bg-sky-300"
end
