defmodule CaseManagerWeb.StatusBadge do
  @moduledoc """
  Provides a badge showing risk or severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.Badge

  @doc """
  Renders a badge showing a status.

  Status come in five categories – tpos (true-positive), benign, pend (pending), fpos (false-positive) and inprog (in progress).
  This attribute is required.

  # Example

      <.status_badge color="tpos" />
      <.status_badge color="benign" />
      <.status_badge color="pend" />
      <.status_badge color="fpos" />
      <.status_badge color="inprog" />
  """
  attr :color, :string, required: true, values: ["tpos", "benign", "pend", "fpos", "inprog"]

  attr :class, :string, default: nil
  attr :rest, :global

  def status_badge(assigns) do
    assigns =
      assigns
      |> assign(:icon_name, icon_name(assigns))
      |> assign(:txt, txt(assigns))
      |> assign(:color_classes, color_classes(assigns))

    ~H"""
    <.badge
      class={[
        @color_classes,
        @class
      ]}
      icon_name={@icon_name}
      txt={@txt}
      {@rest}
    />
    """
  end

  defp icon_name(opts) do
    opts = %{
      color: opts[:color]
    }

    get_icon_name(opts.color)
  end

  defp get_icon_name("tpos"), do: "hero-fire"
  defp get_icon_name("benign"), do: "hero-check-circle"
  defp get_icon_name("pend"), do: "hero-clock"
  defp get_icon_name("fpos"), do: "hero-x-circle"
  defp get_icon_name("inprog"), do: "hero-bolt"

  defp txt(opts) do
    opts = %{
      color: opts[:color]
    }

    get_txt(opts.color)
  end

  defp get_txt("tpos"), do: "T. Positive"
  defp get_txt("benign"), do: "Benign"
  defp get_txt("pend"), do: "Pending"
  defp get_txt("fpos"), do: "F. Positive"
  defp get_txt("inprog"), do: "In Progress"

  defp color_classes(opts) do
    opts = %{
      color: opts[:color]
    }

    get_color_classes(opts.color)
  end

  defp get_color_classes("tpos"), do: "bg-red-300"
  defp get_color_classes("benign"), do: "bg-green-200"
  defp get_color_classes("pend"), do: "bg-amber-100"
  defp get_color_classes("fpos"), do: "bg-gray-300"
  defp get_color_classes("inprog"), do: "bg-sky-300"
end
