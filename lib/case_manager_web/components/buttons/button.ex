defmodule CaseManagerWeb.Button do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """

  attr :color, :string, default: "primary", values: ["primary", "secondary", "critical"]
  
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    assigns = 
      assigns
      |> assign(:color_classes, button_color_classes(assigns))

    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg",
        "text-sm text-white active:text-white/80",
        @color_classes,
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
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
    do: "bg-stone-900 hover:bg-zinc-500"

  defp get_color_classes("secondary"),
    do: "bg-neutral-500 hover:bg-neutral-400"

  defp get_color_classes("critical"),
    do: "bg-red-500 hover:bg-red-400"
end
