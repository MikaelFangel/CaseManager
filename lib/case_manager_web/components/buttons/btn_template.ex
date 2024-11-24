defmodule CaseManagerWeb.BtnTemplate do
  @moduledoc """
  Provides a very general button UI component.
  """

  use Phoenix.Component

  @doc """
  Renders a button template.

  Buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  ## Examples

      <.btn_template>Send!</.button>
      <.btn_template phx-click="go" class="ml-2">Send!</.btn_template>

  """
  attr :colour, :atom,
    default: :primary,
    values: [:primary, :secondary, :tertiary, :disabled, :critical]

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  slot :inner_block, required: true

  def btn_template(%{colour: colour, rest: %{disabled: true}} = assigns)
      when colour != :disabled do
    btn_template(Map.put(assigns, :colour, :disabled))
  end

  def btn_template(%{colour: :disabled, rest: %{disabled: false}} = assigns) do
    btn_template(Map.put(assigns, :disabled, true))
  end

  def btn_template(assigns) do
    assigns =
      assigns
      |> assign(:colour_class, button_colour_class(assigns))

    ~H"""
    <div class="flex items-center h-full">
      <button
        type={@type}
        class={[
          "phx-submit-loading:opacity-75",
          "text-sm",
          @colour_class
        ]}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </button>
    </div>
    """
  end

  defp button_colour_class(%{colour: colour, class: class}), do: [colour_class(colour), class]
  defp button_colour_class(%{colour: colour}), do: colour_class(colour)

  defp colour_class(:primary),
    do: "bg-slate-950 hover:bg-zinc-500 text-white active:text-white/80"

  defp colour_class(:secondary),
    do: "bg-neutral-400 hover:bg-neutral-300 text-white active:text-white/80"

  defp colour_class(:tertiary),
    do:
      "bg-white hover:bg-neutral-100 text-slate-950 active:text-slate-950/50 border border-slate-950"

  defp colour_class(:disabled), do: "bg-zinc-300 text-white"

  defp colour_class(:critical),
    do: "bg-rose-500 hover:bg-rose-400 text-white active:text-white/80"
end
