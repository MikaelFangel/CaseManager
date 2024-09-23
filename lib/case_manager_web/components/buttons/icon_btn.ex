defmodule CaseManagerWeb.IconBtn do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  import CaseManagerWeb.Icon
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders an Icon button

  Icon buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  Icon buttons come in three sizes – large and small.
  By default, the large size is used, but the size may
  be applied by using the size parameter.
  """
  attr :size, :string, default: "large", values: ["large", "small"]
  attr :color, :string, default: "primary", values: ["primary", "secondary", "critical"]

  attr :icon_name, :string, required: true

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  # If the default slot is omitted a warning will appear
  slot :inner_block, required: true

  def icon_button(%{icon_name: "hero-" <> _} = assigns) do
    assigns = 
      assigns
      |> assign(:icon_button_size_classes, icon_button_size_classes(assigns))
      |> assign(:icon_size_classes, icon_size_classes(assigns))

    ~H"""
    <.button
      color={@color}
      type={@type}
      class={@icon_button_size_classes}
      {@rest}
    >
      <.icon name={@icon_name} class={@icon_size_classes}/>
    </.button>

    """
  end

  defp icon_button_size_classes(opts) do
    opts = %{
      color: opts[:size] || "large",
      class: opts[:class] || ""
    }

    color_css = get_icon_button_size_classes(opts.color)
    custom_size_classes = opts.class

    [color_css, custom_size_classes]
  end

  defp get_icon_button_size_classes("large"),
    do: "w-11 h-11"

  defp get_icon_button_size_classes("small"),
    do: "w-7 h-7"

  defp icon_size_classes(opts) do
    opts = %{
      color: opts[:size] || "large",
      class: opts[:class] || ""
    }

    color_css = get_icon_size_classes(opts.color)
    custom_size_classes = opts.class

    [color_css, custom_size_classes]
  end

  defp get_icon_size_classes("large"),
    do: "w-6 h-6"

  defp get_icon_size_classes("small"),
    do: "w-4 h-4"
end

