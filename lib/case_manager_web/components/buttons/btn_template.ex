defmodule CaseManagerWeb.BtnTemplate do
  @moduledoc """
  Provides a very general button UI component.
  """

  use Phoenix.Component

  @doc """
  Renders a button template.

  Buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  ## Examples

      <.btn_template>Send!</.button>
      <.btn_template phx-click="go" class="ml-2">Send!</.btn_template>

  """
  attr :color, :string,
    default: "primary",
    values: ["primary", "secondary", "disabled", "critical"]

  attr :disabled?, :boolean, default: false
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def btn_template(%{disabled?: true, color: color} = assigns) when color != "disabled" do
    btn_template(Map.put(assigns, :color, "disabled"))
  end

  def btn_template(%{disabled?: false, color: "disabled"} = assigns) do
    btn_template(Map.put(assigns, :disabled, true))
  end

  def btn_template(assigns) do
    assigns =
      assigns
      |> assign(:color_classes, button_color_classes(assigns))

    ~H"""
    <div class="flex items-center h-full">
      <button
        type={@type}
        class={[
          "phx-submit-loading:opacity-75",
          "text-sm text-white",
          @color_classes
        ]}
        disabled={@disabled?}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </button>
    </div>
    """
  end

  defp button_color_classes(opts) do
    opts = %{
      color: opts[:color] || "primary",
      class: opts[:class] || ""
    }

    color_css = get_color_classes(opts.color)
    custom_button_classes = opts.class

    [color_css, custom_button_classes]
  end

  defp get_color_classes("primary"),
    do: "bg-slate-950 hover:bg-zinc-500 active:text-white/80"

  defp get_color_classes("secondary"),
    do: "bg-neutral-500 hover:bg-neutral-400 active:text-white/80"

  defp get_color_classes("disabled"),
    do: "bg-gray-300"

  defp get_color_classes("critical"),
    do: "bg-rose-500 hover:bg-rose-400 active:text-white/80"
end
