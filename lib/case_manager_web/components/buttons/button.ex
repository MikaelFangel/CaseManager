defmodule CaseManagerWeb.Button do
  @moduledoc """
  Provides a custom button UI component.
  """

  use Phoenix.Component
  import CaseManagerWeb.BtnTemplate
  import CaseManagerWeb.Icon

  @base_class "h-11 px-5 font-semibold rounded-xl"

  @doc """
  Renders a custom button with content. 

  Custom buttons come with a hero icon if the icon_name atribute is specified.

  The text of the button can either be specified using the default slot or the txt attribute.

  Custom buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  # Examples
        
      <.button txt="Simple primary text button" />
      <.button icon_name="hero-user-plus">Simple primary button with icon</.button>
      <.button color="secondary" txt="Simple secondary text button" />
      <.button color="critical" txt="Simple critical text button" />
      <.button disabled txt="Simple disabled text button" phx-click="show_modal" />
      <.button color="disabled" txt="Simple disabled text button" phx-click="show_modal" />

  """
  attr :colour, :atom,
    default: :primary,
    values: [:primary, :secondary, :disabled, :critical]

  attr :icon_name, :string, default: nil, doc: "name of hero icon used lhs"
  attr :label, :string, default: nil, doc: "text written on button"
  attr :disabled?, :boolean, default: false

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)
  slot :inner_block, required: false

  def button(assigns) do
    assigns =
      assigns
      |> assign(:btn_class, btn_class(assigns))

    ~H"""
    <%= unless txt_blank?(@label, @inner_block) do %>
      <.btn_template disabled?={@disabled?} colour={@colour} type={@type} class={@btn_class} {@rest}>
        <%= if @icon_name && String.starts_with?(@icon_name, "hero-") do %>
          <.icon name={@icon_name} class="w-6 h-6 mr-1" />
        <% end %>

        <%= render_slot(@inner_block) || @label %>
      </.btn_template>
    <% end %>
    """
  end

  defp btn_class(%{class: class}), do: [@base_class, class]
  defp btn_class(_opts), do: @base_class

  defp txt_blank?(label, inner_block) do
    # Label is negated to convert it from a truthy/falsy value to a boolean value
    (!label || label == "") && inner_block == []
  end
end
