defmodule CaseManagerWeb.TxtIconBtn do
  @moduledoc """
  Provides a custom text icon button UI component.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  import CaseManagerWeb.Icon
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a button with an icon and some text (or some other component)

  ## Examples

    <.txt_icon_btn icon_name="hero-document-plus">Create Case</.txt_icon_btn>
    <.txt_icon_btn icon_name="hero-user-plus">Create User</.txt_icon_btn>
    <.txt_icon_btn icon_name="hero-user-plus">Create Team</.txt_icon_btn>
  """
  attr :icon_name, :string, required: true

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  # If the default slot is omitted a warning will appear
  slot :inner_block, required: true

  def txt_icon_btn(%{icon_name: "hero-" <> _} = assigns) do
    ~H"""
    <.button
      color="primary"
      type={@type}
      class="h-11 align-middle text-left px-2.5 font-semibold"
      {@rest}
    >
      <.icon name={@icon_name} class="w-6 h-6 mr-1"/>
      <%= render_slot(@inner_block) %>
    </.button>

    """
  end
end
