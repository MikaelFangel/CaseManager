defmodule CaseManagerWeb.CaseLive.Components.Table do
  @moduledoc false
  use CaseManagerWeb, :live_component

  alias CaseManagerWeb.CaseLive.Components.{CustomerTable, MSSPTable}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        id="cases-container"
        class="mt-12"
        phx-update="stream"
        phx-viewport-bottom={@more_pages? && "load_more_cases"}
      >
        <%= if @role == :mssp do %>
          <.live_component module={MSSPTable} id="mssp-table" rows={@rows} row_click={@row_click} />
        <% else %>
          <.live_component
            module={CustomerTable}
            id="customer-table"
            rows={@rows}
            row_click={@row_click}
          />
        <% end %>
      </div>
      <%= if @more_pages? do %>
        <div class="flex justify-center my-4">
          <.button phx-click="load_more_cases"><%= gettext("Load More") %></.button>
        </div>
      <% else %>
        <div class="flex justify-center my-4">
          <span class="text-black text-xs font-semibold"><%= gettext("No more cases") %></span>
        </div>
      <% end %>
    </div>
    """
  end
end
