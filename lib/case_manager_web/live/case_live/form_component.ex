defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input name="title" label="Title" field={@form[:title]} type="text" />
        <hr />
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
                  <.link navigate={alert.link} target="_blank"><%= alert.link %></.link>
                </:col>
              </.table>
              <div class="my-4">
                <.input
                  name="internal_note"
                  field={@form[:internal_note]}
                  label="Internal Note"
                  type="textarea"
                  class="h-[200px]"
                />
              </div>
              <.input
                name="team_id"
                field={@form[:team_id]}
                type="hidden"
                value={
                  @selected_alerts
                  |> Enum.take(1)
                  |> then(fn [{_id, alert} | _xs] -> alert.team.id end)
                }
              />
              <.input name="priority" field={@form[:priority]} type="hidden" value="low" } />
              <.input name="escalated" field={@form[:priority]} type="hidden" value="false" />
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
    form =
      CaseManager.Cases.Case
      |> AshPhoenix.Form.for_create(:create,
        forms: [
          case: [
            resource: CaseManager.Cases.Case,
            create_action: :create
          ]
        ],
        domain: CaseManager.Cases
      )
      |> AshPhoenix.Form.add_form([:case])
      |> to_form()

    {:ok,
     assign(socket, :form, form)
     |> assign(:selected_alerts, assigns[:selected_alerts] || [])}
  end

  def handle_event("validate", params, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Case created successfully.")
         |> push_navigate(to: "/cases")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)} |> dbg
    end
  end
end
