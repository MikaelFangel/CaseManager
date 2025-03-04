defmodule CaseManagerWeb.HorizontalCards do
  @moduledoc false

  use Phoenix.Component

  attr :cards, :list, default: [], doc: "List of cards to display"
  attr :class, :string, default: "p-2 h-48 min-w-32 max-w-64 flex-shrink-0 rounded-md bg-slate-50 shadow"
  attr :inner_content, :any, required: true, doc: "Function to render each card"

  def horizontal_cards(assigns) do
    ~H"""
    <div class="w-full overflow-hidden" id="cards-container" phx-hook="DraggableScroll">
      <div class="flex gap-4 pb-2 cursor-grab active:cursor-grabbing" id="cards-wrapper">
        <%= for card <- @cards do %>
          <div class={@class}>
            {render_slot(@inner_content, card)}
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
