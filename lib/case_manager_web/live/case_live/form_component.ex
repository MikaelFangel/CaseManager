defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>Important Form Header</.header>
      <hr />
      <.simple_form for={@form} id="case-form" phx-target={@myself} phx-submit="save">
        <div class="px-2">
          <div class="flex -mx-2">
            <div class="w-1/3 px-2">
              <div class="grid grid-cols-3 text-sm items-center">
                <div class="flex items-center">
                  Customer: <%= @selected_alerts
                  |> Enum.take(1)
                  |> then(fn [{_id, alert} | _xs] -> alert.team.name end) %>
                </div>
                <div class="flex items-center">
                  Priority:
                  <.risk_badge colour={
                    @selected_alerts
                    |> Enum.take(1)
                    |> then(fn [{_id, alert} | _xs] -> alert.risk_level end)
                  }>
                  </.risk_badge>
                </div>
                <div class="flex items-center">
                  Status:
                  <.status_badge colour={:in_progress}></.status_badge>
                </div>
              </div>
              <.input
                name="description"
                field={@form[:description]}
                label="Description"
                type="textarea"
                class="h-[530px]"
                value=""
              />
            </div>
            <div class="w-2/3 px-2">
              <.table id="alerts" rows={@selected_alerts} row_click={}>
                <:col :let={{_id, alert}} label={gettext("Title")}><%= alert.title %></:col>
                <:col :let={{_id, alert}} label={gettext("Risk Level")} width="16">
                  <.risk_badge colour={alert.risk_level} />
                </:col>
                <:col :let={{_id, alert}} label={gettext("Creation Time")}>
                  <%= alert.creation_time %>
                </:col>
                <:col :let={{_id, alert}} label={gettext("Link")} width="8" not_clickable_area?>
                  <.icon_btn
                    icon_name="hero-arrow-top-right-on-square"
                    colour={:secondary}
                    size={:small}
                    class="pl-0.5 pb-1"
                    phx-click={alert.link}
                  />
                  <!-- <.link navigate={alert.link} target="_blank"><%= alert.link %></.link> -->
                </:col>
              </.table>
              <div class="mt-4">
                <.input
                  name="internal_note"
                  field={@form[:internal_note]}
                  label="Internal Note"
                  type="textarea"
                  class="h-[200px]"
                  value=""
                />
              </div>
            </div>
          </div>
        </div>

        <:actions>
          <div class="flex justify-end w-full gap-4">
            <.button phx-disable-with="Saving...">Save</.button>
            <.button colour={:critical} phx-disable-with="Saving..." phx-click="save_escalate">
              Save & Escalate
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     assign(socket, :form, assigns[:form] || %{})
     |> assign(:selected_alerts, assigns[:selected_alerts] || [])}
  end
end
