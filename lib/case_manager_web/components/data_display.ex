defmodule CaseManagerWeb.DataDisplay do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a status indicator

  ## Examples

      <.status type="info" />
      <.status type="error" animation="bounce" />
  """

  attr :type, :atom,
    values: [:primary, :secondary, :accent, :neutral, :info, :success, :warning, :error, nil],
    default: nil

  attr :animation, :atom, values: [:ping, :bounce, nil], default: nil

  def status(assigns) do
    classes =
      ["status", assigns.type && "status-#{assigns.type}", assigns.animation && "animate-#{assigns.animation}"]

    assigns =
      assigns
      |> assign(:class, classes)
      |> assign_new(:label, fn ->
        if assigns[:type] in [:primary, :secondary, :accent, :neutral, nil],
          do: "status",
          else: assigns.type
      end)

    ~H"""
    <div aria-label={@label} class={@class} />
    """
  end

  @doc """
  Renders a badge

  ## Examples

      <.badge type="success">Success</.badge>
      <.badge type="error">Error</.badge>
  """

  attr :type, :atom,
    values: [:primary, :secondary, :accent, :neutral, :info, :success, :warning, :error, nil],
    default: nil

  attr :modifier, :atom, values: [:dash, :outline, :soft, :ghost, nil], default: nil

  slot :inner_block

  def badge(assigns) do
    classes = ["badge", assigns.type && "badge-#{assigns.type}", assigns.modifier && "badge-#{assigns.modifier}"]

    assigns = assign(assigns, :class, classes)

    ~H"""
    <div class={@class}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
