defmodule CaseManagerWeb.IconBtn do
  @moduledoc """
  Provides a custom button that only displays an icon.
  """

  use Phoenix.Component

  import CaseManagerWeb.BtnTemplate
  import CaseManagerWeb.Icon

  @doc """
  Renders a square icon button.

  Icon buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  Icon buttons come in three sizes – large and small.
  By default, the large size is used, but the size may
  be applied by using the size parameter.

  ## Examples

      <.icon_btn icon_name="hero-pause-circle" colour="critical" />
      <.icon_btn icon_name="hero-arrow-top-right-on-square" colour="secondary" size="small" class="pl-0.5 pb-1" />

  """
  attr :size, :atom, default: :large, values: [:large, :small]

  attr :colour, :atom,
    default: :primary,
    values: [:primary, :secondary, :tertiary, :disabled, :critical]

  attr :icon_name, :string, required: true

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  def icon_btn(%{icon_name: "hero-" <> _} = assigns) do
    assigns =
      assigns
      |> assign(:btn_size_class, btn_size_class(assigns))
      |> assign(:icon_size_class, icon_size_class(assigns))

    ~H"""
    <.btn_template colour={@colour} type={@type} class={@btn_size_class} {@rest}>
      <.icon name={@icon_name} class={@icon_size_class} />
    </.btn_template>
    """
  end

  defp btn_size_class(%{size: size, class: class}), do: [btn_size_class(size), class]
  defp btn_size_class(%{size: size}), do: btn_size_class(size)

  defp btn_size_class(:large), do: "w-11 h-11 rounded-xl"
  defp btn_size_class(:small), do: "w-7 h-7 rounded-lg"

  defp icon_size_class(%{size: size, class: class}), do: [icon_size_class(size), class]

  defp icon_size_class(:large), do: "w-6 h-6"
  defp icon_size_class(:small), do: "w-4 h-4"
end
