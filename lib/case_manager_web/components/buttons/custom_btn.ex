defmodule CaseManagerWeb.CustomBtn do
  @moduledoc """
  Provides a custom button UI component.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  import CaseManagerWeb.Icon

  @doc """
  Renders a custom button with content. 

  Custom buttons come with a hero icon if the icon_name atribute is specified.

  The text of the button can either be specified using the default slot or the txt attribute.

  Custom buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  # Examples
        
      <.custom_btn txt="Simple primary text button" />
      <.custom_btn icon_name="hero-user-plus">Simple primary text button</.custom_btn>
      <.custom_btn color="secondary" txt="Simple secondary text button" />
  """
  attr :color, :string, default: "primary", values: ["primary", "secondary", "disabled", "critical"]

  attr :icon_name, :string, default: nil, doc: "name of icon used lhs"
  attr :txt, :string, default: nil, doc: "txt written on btn"

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)
  slot :inner_block

  def custom_btn(assigns) do
    assigns =
      assigns
      |> assign(:btn_classes, btn_classes(assigns))

    ~H"""
    <%= unless txt_blank?(@txt, @inner_block) do %>
      <.button color={@color} type={@type} class={@btn_classes} {@rest}>
        <%= if @icon_name && String.starts_with?(@icon_name, "hero-") do %>
          <.icon name={@icon_name} class="w-6 h-6 mr-1" />
        <% end %>

        <%= render_slot(@inner_block) || @txt %>
      </.button>
    <% end %>
    """
  end

  defp btn_classes(opts) do
    opts = %{
      class: opts[:class] || ""
    }

    base_classes = "h-11 px-5 font-semibold rounded-xl"
    custom_classes = opts.class

    [base_classes, custom_classes]
  end

  defp txt_blank?(txt, inner_block) do
    (!txt || txt == "") && inner_block == []
  end
end