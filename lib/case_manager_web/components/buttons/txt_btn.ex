defmodule CaseManagerWeb.TxtBtn do
  @moduledoc """
  Provides a custom text button UI component.
  """

  use Phoenix.Component
  import CaseManagerWeb.Button
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a button. The typical height and padding is preset, when using this button.

  This button is intended for text buttons, but you can also add other components like an icon.

  Text buttons come in three colors – primary, secondary, and critical.
  By default, the primary color is used, but the color may
  be applied by using the color parameter.

  # Examples
        
      <.txt_btn>Simple primary text buttons</.txt_btn>
      <.txt_btn color="secondary">Simple secondary text button</.txt_btn>
      <.txt_btn color="critical">Simple critical text button</.txt_btn>
  """
  attr :color, :string, default: "primary", values: ["primary", "secondary", "critical"]

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def txt_btn(assigns) do
    assigns =
      assigns
      |> assign(:btn_classes, btn_classes(assigns))

    ~H"""
    <.button color={@color} type={@type} class={@btn_classes} {@rest}>
      <%= render_slot(@inner_block) %>
    </.button>
    """
  end

  defp btn_classes(opts) do
    opts = %{
      class: opts[:class] || ""
    }

    base_classes = "h-11 px-7 font-semibold"
    custom_classes = opts.class

    [base_classes, custom_classes]
  end
end
