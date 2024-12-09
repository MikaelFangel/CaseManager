defmodule CaseManagerWeb.Tooltip do
  @moduledoc """
  Provides a hoverable item with a tooltip.
  """

  use Phoenix.Component

  @tooltip_body "
    w-max 
    bg-slate-950 text-white 
    text-xs font-semibold text-center 
    py-1 px-1.5 
    rounded-md 
    absolute 
    z-10
    "

  @doc """
  Renders a hoverable item with a tooltip.

  # Example

      <.tooltip pos="right" tooltip_txt="right tooltip">Hoverable text</.tooltip>
      <.tooltip pos="left" tooltip_txt="left tooltip">Hoverable text</.tooltip>
      <.tooltip pos="top" tooltip_txt="top tooltip">Hoverable text</.tooltip>
      <.tooltip pos="bottom" tooltip_txt="bottom tooltip">Hoverable text</.tooltip>

  The hoverable item can be a clickable text.

  # Example 
    
      <.tooltip pos="top" tooltip_txt="right tooltip">
        <.txt_link phx-click="go" txt="I am clickable text" />
      </.tooltip>

  """
  attr :pos, :atom, default: :top, values: [:top, :bottom, :left, :right]
  attr :tooltip_label, :string, required: true, doc: "tooltip label"

  slot :inner_block, required: true, doc: "Hoverable item, e.g. text or button"

  def tooltip(assigns) do
    assigns =
      assigns
      |> assign(:tooltip_body, @tooltip_body)
      |> assign(:tooltip_arrow, tooltip_arrow(assigns))
      |> assign(:tooltip_pos, tooltip_pos(assigns))

    ~H"""
    <div class="group relative">
      <!-- Tooltip body -->
      <span class={[
        "hidden",
        "group-hover:block",
        "transform",
        @tooltip_body,
        @tooltip_arrow,
        @tooltip_pos
      ]}>
        {@tooltip_label}
      </span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp tooltip_arrow(%{pos: pos}), do: tooltip_arrow(pos)

  defp tooltip_arrow(:bottom), do: "
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

  defp tooltip_arrow(:top), do: "
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

  defp tooltip_arrow(:left), do: "
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

  defp tooltip_arrow(:right), do: "
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

  defp tooltip_pos(%{pos: pos, class: class}), do: [tooltip_pos(pos), class]
  defp tooltip_pos(%{pos: pos}), do: tooltip_pos(pos)

  defp tooltip_pos(:top), do: "bottom-[120%] left-1/2 -translate-x-1/2"
  defp tooltip_pos(:bottom), do: "top-[120%] left-1/2 -translate-x-1/2"
  defp tooltip_pos(:right), do: "left-[120%] top-1/2 -translate-y-1/2"
  defp tooltip_pos(:left), do: "right-[120%] top-1/2 -translate-y-1/2"
end
