defmodule CaseManagerWeb.CreateCaseBtn do
  @moduledoc """
  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  import CaseManagerWeb.Icon
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a Create Case button
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  # If the default slot is omitted a warning will appear
  slot :inner_block, required: true

  def create_case_button(assigns) do
    ~H"""
    <.button
      color="primary"
      type={@type}
      class="h-11 w-40 align-middle text-left px-2.5 font-bold"
      {@rest}
    >
      <.icon name="hero-document-plus" class="w-6 h-6 mr-1"/>
      Create Case
    </.button>

    """
  end
end
