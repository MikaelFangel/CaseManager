defmodule CaseManagerWeb.Tooltip do
  @moduledoc """
  Provides a hoverable item with a tooltip
  """

  use Phoenix.Component

  attr :pos, :string, default: "top", values: ["top", "bottom", "left", "right"]
  attr :tooltip_txt, :string, required: true, default: nil, doc: "tooltip text"

  slot :inner_block, required: true, doc: "Hoverable item, e.g. text or button"

  def tooltip(assigns) do
    assigns =
      assigns
      |> assign(:tooltip_body, get_tooltip_body())
      |> assign(:tooltip_arrow, tooltip_arrow(assigns))
      |> assign(:tooltip_pos, tooltip_pos(assigns))

    ~H"""
    <div class="group relative inline-block">
      <!-- Tooltip body -->
      <span class={[
        "hidden",
        "group-hover:block",
        "transform",
        @tooltip_body, 
        @tooltip_arrow,
        @tooltip_pos
      ]}>
        <%= @tooltip_txt %>
      </span>

      <!-- Hoverable item -->
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp get_tooltip_body, do: "
    w-max 
    bg-slate-950 text-white 
    text-xs font-semibold text-center 
    py-1 px-1.5 
    rounded-md 
    absolute 
    z-10
    "

  defp tooltip_arrow(opts) do
    opts = %{
      pos: opts[:pos] || "top",
    }

    tooltip_css = get_tooltip_arrow(opts.pos)

    [tooltip_css]
  end

  defp get_tooltip_arrow("bottom"),
    do: "
    after:absolute
    after:border-b-8
    after:border-l-4
    after:border-r-4
    after:bottom-[97%]
    after:-translate-x-1/2
    after:left-1/2
    after:border-b-slate-950
    after:border-t-transparent 
    after:border-l-transparent
    after:border-r-transparent
    "

  defp get_tooltip_arrow("top"),
    do: "
    after:absolute
    after:border-t-8
    after:border-l-4
    after:border-r-4
    after:top-[97%]
    after:-translate-x-1/2
    after:left-1/2
    after:border-t-slate-950
    after:border-b-transparent 
    after:border-l-transparent
    after:border-r-transparent
    "

  defp get_tooltip_arrow("left"),
    do: "
    after:absolute
    after:border-l-8
    after:border-t-4
    after:border-b-4
    after:left-[99%]
    after:translate-y-1/2
    after:border-l-slate-950
    after:border-b-transparent 
    after:border-t-transparent
    after:border-r-transparent
    "

  defp get_tooltip_arrow("right"),
    do: "
    after:absolute
    after:border-r-8
    after:border-t-4
    after:border-b-4
    after:right-[99%]
    after:translate-y-1/2
    after:border-r-slate-950
    after:border-b-transparent 
    after:border-l-transparent
    after:border-t-transparent
    "

  defp tooltip_pos(opts) do
    opts = %{
      pos: opts[:pos] || "top",
      class: opts[:class] || ""
    }

    tooltip_css = get_tooltip_pos(opts.pos)
    custom_tooltip_classes = opts.class

    [tooltip_css, custom_tooltip_classes]
  end

  defp get_tooltip_pos("top"),
    do: "bottom-[120%] left-1/2 -translate-x-1/2"

  defp get_tooltip_pos("bottom"),
    do: "top-[120%] left-1/2 -translate-x-1/2"

  defp get_tooltip_pos("right"),
    do: "left-[120%] top-1/2 -translate-y-1/2"

  defp get_tooltip_pos("left"),
    do: "right-[120%] top-1/2 -translate-y-1/2"
end