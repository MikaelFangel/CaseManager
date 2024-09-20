defmodule CaseManagerWeb.IconLinkBtn do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  import CaseManagerWeb.Icon
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a Link Icon button
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  # If the default slot is omitted a warning will appear
  slot :inner_block, required: true

  def icon_link_button(assigns) do
    ~H"""

    <.button
      color="secondary"
      type={@type}
      class="w-7 h-7"
      {@rest}
    >
      <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 ml-0.5 mb-0.5" />
    </.button>
    """
  end
end

