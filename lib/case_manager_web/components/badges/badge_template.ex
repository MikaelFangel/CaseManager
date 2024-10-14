defmodule CaseManagerWeb.BadgeTemplate do
  @moduledoc """
  Provides a bagde for showing things like severity level.
  """

  use Phoenix.Component
  import CaseManagerWeb.Icon

  @container_class "inline-flex items-center justify-center rounded-[5px] focus:outline-none h-6 px-[5px] gap-[5px]"
  @txt_class "text-black text-xs font-semibold"
  @icon_class "w-6 h-6 relative"

  @doc """
  Renders a badge template
  """
  attr :icon_name, :string, default: nil, doc: "name of hero icon used lhs"
  attr :txt, :string, default: nil, doc: "txt written on badge"

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: false

  def badge_template(assigns) do
    assigns =
      assigns
      |> assign(:badge_class, badge_class(assigns))
      |> assign(:icon_class, @icon_class)

    ~H"""
    <%= unless txt_blank?(@txt, @inner_block) do %>
      <span class={@badge_class} {@rest}>
        <%= if @icon_name && String.starts_with?(@icon_name, "hero-") do %>
          <.icon name={@icon_name} class={@icon_class} />
        <% end %>

        <%= render_slot(@inner_block) || @txt %>
      </span>
    <% end %>
    """
  end

  defp badge_class(%{class: class}), do: [@container_class, @txt_class, class]
  defp badge_class(_opts), do: [@container_class, @txt_class]

  defp txt_blank?(txt, inner_block) do
    (!txt || txt == "") && inner_block == []
  end
end
