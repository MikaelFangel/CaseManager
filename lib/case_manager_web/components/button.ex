defmodule CaseManagerWeb.Buttons do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  import CaseManagerWeb.Icon
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
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @color_classes,
        @class
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
    }

    color_css = get_color_classes(opts.color)

    [color_css]
  end

  defp get_color_classes("primary"),
    do: "bg-info-100"

  defp get_color_classes("secondary"),
    do: "bg-stone-700"

  defp get_color_classes("critical"),
    do: "bg-red-600"
end

