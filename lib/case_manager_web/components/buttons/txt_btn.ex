defmodule CaseManagerWeb.TxtBtn do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a text button
  """
  attr :color, :string, default: "primary", values: ["primary", "secondary", "critical"]
  
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def text_button(assigns) do
    ~H"""
    <.button
      color={@color}
      type={@type}
      class="h-11 px-7 font-semibold"
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.button>

    """
  end
end
