defmodule CaseManagerWeb.IconBtn do
  @moduledoc """
  Provides a custom button that only displays an icon.
  """

  use Phoenix.Component
  import CaseManagerWeb.BtnTemplate
  import CaseManagerWeb.Icon

  @doc """
  Renders a square icon button

  Icon buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  Icon buttons come in three sizes – large and small.
  By default, the large size is used, but the size may
  be applied by using the size parameter.

  ## Examples

      <.icon_btn icon_name="hero-pause-circle" color="critical" />
      <.icon_btn icon_name="hero-arrow-top-right-on-square" color="secondary" size="small" class="pl-0.5 pb-1" />
  """
  attr :size, :string, default: "large", values: ["large", "small"]

  attr :color, :string,
    default: "primary",
    values: ["primary", "secondary", "disabled", "critical"]

  attr :icon_name, :string, required: true

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  def icon_btn(%{icon_name: "hero-" <> _} = assigns) do
    assigns =
      assigns
      |> assign(:btn_size_classes, btn_size_classes(assigns))
      |> assign(:icon_size_classes, icon_size_classes(assigns))

    ~H"""
    <.btn_template color={@color} type={@type} class={@btn_size_classes} {@rest}>
      <.icon name={@icon_name} class={@icon_size_classes} />
    </.btn_template>
    """
  end

  defp btn_size_classes(opts) do
    opts = %{
      color: opts[:size] || "large",
      class: opts[:class] || ""
    }

    size_css = get_icon_btn_size_classes(opts.color)
    custom_btn_size_classes = opts.class

    [size_css, custom_btn_size_classes]
  end

  defp get_icon_btn_size_classes("large"),
    do: "w-11 h-11 rounded-xl"

  defp get_icon_btn_size_classes("small"),
    do: "w-7 h-7 rounded-lg"

  defp icon_size_classes(opts) do
    opts = %{
      color: opts[:size] || "large",
      class: opts[:class] || ""
    }

    icon_size_css = get_icon_size_classes(opts.color)
    custom_icon_size_classes = opts.class

    [icon_size_css, custom_icon_size_classes]
  end

  defp get_icon_size_classes("large"),
    do: "w-6 h-6"

  defp get_icon_size_classes("small"),
    do: "w-4 h-4"
end
