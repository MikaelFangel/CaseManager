defmodule CaseManagerWeb.Badge do
  @moduledoc """
  Provides a bagde for showing things like severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.Icon

  @doc """
  Renders a generic badge
  """
  attr :icon_name, :string, default: nil, doc: "name of icon used lhs"
  attr :txt, :string, default: nil, doc: "txt written on badge"

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: false

  def badge(assigns) do
    assigns =
      assigns
      |> assign(:container_class, get_container_classes())
      |> assign(:txt_classes, get_txt_classes())
      |> assign(:icon_classes, get_icon_classes())

    ~H"""
    <%= unless txt_blank?(@txt, @inner_block) do %>
      <span
        class={[
          @container_class,
          @txt_classes,
          @class
        ]}
        {@rest}
      >
        <%= if @icon_name && String.starts_with?(@icon_name, "hero-") do %>
          <.icon name={@icon_name} class={@icon_classes} />
        <% end %>

        <%= render_slot(@inner_block) || @txt %>
      </span>
    <% end %>
    """
  end

  defp get_container_classes,
    do:
      "inline-flex items-center justify-center rounded-[5px] focus:outline-none h-6 px-[5px] gap-[5px]"

  defp get_txt_classes, do: "text-black text-xs font-semibold"

  defp get_icon_classes, do: "w-6 h-6 relative"

  defp txt_blank?(txt, inner_block) do
    (!txt || txt == "") && inner_block == []
  end
end
