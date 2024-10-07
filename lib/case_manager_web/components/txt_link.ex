defmodule CaseManagerWeb.TxtLink do
  @moduledoc """
  Provides a clickable underlined Text
  """

  use Phoenix.Component

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  attr :txt, :string, required: true, doc: "displayed text"

  @doc """
  Renders an underlined text that is clickable

  # Example
    
      <.txt_link phx-click="go" txt="I am clickable text" />

  """
  def txt_link(assigns) do
    assigns =
      assigns
      |> assign(:txt_style, get_txt_style())

    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75",
        "bg-none border-none",
        @txt_style
      ]}
      {@rest}
    >
      <%= @txt %>
    </button>
    """
  end

  defp get_txt_style,
    do: "text-sm text-black font-semibold underline active:text-black/60 hover:opacity-60"
end
