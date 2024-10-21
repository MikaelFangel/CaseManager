defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="w-1/3 px-8">
          <.input name="title" label="Title" field={@form[:title]} type="text" />
        </div>
        <div class="px-8">
          <div class="flex -mx-8">
            <div class="w-1/3 px-8">
              <div class="grid grid-cols-[150px_1fr] text-sm items-center mb-4">
                <span>Customer:</span>
                <div>
                  <%= @selected_alerts
                  |> Enum.take(1)
                  |> then(fn [{_id, alert} | _xs] -> alert.team.name end) %>
                </div>
                <span>Priority:</span>
                <div>
                  <.input
                    name="priority"
                    type="select"
                    field={@form[:priority]}
                    options={[
                      {"Select a priority", ""},
                      {"Info", :info},
                      {"Low", :low},
                      {"Medium", :medium},
                      {"High", :high},
                      {"Critical", :critical}
                    ]}
                  />
                </div>
                <span>Status:</span>
                <div>
                  <.input
                    name="status"
                    type="select"
                    field={@form[:status]}
                    options={[
                      {"In Progress", :in_progress},
                      {"Pending", :pending},
                      {"True Positive", :t_positive},
                      {"False Positive", :f_positive},
                      {"Benign", :benign}
                    ]}
                  />
                </div>
              </div>
              <.input
                name="description"
                field={@form[:description]}
                label="Description"
                type="textarea"
                class="h-[355px]"
              />
            </div>
            <div class="w-2/3 px-8 -mt-8">
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
      |> Form.for_create(:create,
        forms: [
          case: [
            resource: CaseManager.Cases.Case,
            create_action: :create,
            actor: assigns[:current_user]
          ]
        ],
        domain: CaseManager.Cases
      )
      |> Form.add_form([:case])
      |> to_form()

    {:ok,
     assign(socket, :form, form)
     |> assign(:selected_alerts, assigns[:selected_alerts] || [])
     |> assign(:current_user, assigns[:current_user]) || nil}
  end

  def handle_event("validate", params, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    team_id =
      socket.assigns.selected_alerts |> Enum.at(0) |> elem(1) |> Map.get(:team) |> Map.get(:id)

    params =
      Map.put(params, :team_id, team_id)
      |> Map.put(:escalated, false)

    selected_alert_ids =
      socket.assigns.selected_alerts
      |> Enum.map(fn {_id, alert} -> alert.id end)

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, result} ->
        # Manually create relations due to an issue with updates on paginated resources
        selected_alert_ids
        |> Enum.each(fn alert_id ->
          CaseManager.Relationships.CaseAlert
          |> Ash.Changeset.for_create(:create, %{
            case_id: result.id,
            alert_id: alert_id
          })
          |> Ash.create!()
        end)

        {:noreply,
         socket
         |> put_flash(:info, "Case created successfully.")
         |> push_navigate(to: "/")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
