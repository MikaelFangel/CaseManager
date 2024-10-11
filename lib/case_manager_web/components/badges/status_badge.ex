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

      <.status_badge color={:t_positive} />
      <.status_badge color={:benign} />
      <.status_badge color={:pending} />
      <.status_badge color={:f_positive} />
      <.status_badge color={:in_progress} />

  """
  attr :color, :atom,
    required: true,
    values: [:t_positive, :benign, :pending, :f_positive, :in_progress]

  attr :class, :string, default: nil
  attr :rest, :global

  def status_badge(assigns) do
    assigns =
      assigns
      |> assign(:icon_name, icon_name(assigns))
      |> assign(:txt, txt(assigns))
      |> assign(:badge_classes, badge_classes(assigns))

    ~H"""
    <.badge_template class={@badge_classes} icon_name={@icon_name} txt={@txt} {@rest} />
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

  defp get_icon_name(:t_positive), do: "hero-fire"
  defp get_icon_name(:benign), do: "hero-check-circle"
  defp get_icon_name(:pending), do: "hero-clock"
  defp get_icon_name(:f_positive), do: "hero-x-circle"
  defp get_icon_name(:in_progress), do: "hero-bolt"

  defp txt(opts) do
    opts = %{
      color: opts[:color]
    }

    get_txt(opts.color)
  end

  defp get_txt(:t_positive), do: gettext("T. Positive")
  defp get_txt(:benign), do: gettext("Benign")
  defp get_txt(:pending), do: gettext("Pending")
  defp get_txt(:f_positive), do: gettext("F. Positive")
  defp get_txt(:in_progress), do: gettext("In Progress")

  defp color_classes(opts) do
    opts = %{
      color: opts[:color]
    }

    get_color_classes(opts.color)
  end

  defp get_color_classes(:t_positive), do: "bg-red-300"
  defp get_color_classes(:benign), do: "bg-green-200"
  defp get_color_classes(:pending), do: "bg-amber-100"
  defp get_color_classes(:f_positive), do: "bg-gray-300"
  defp get_color_classes(:in_progress), do: "bg-sky-300"
end
