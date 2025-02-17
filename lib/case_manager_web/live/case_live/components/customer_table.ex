defmodule CaseManagerWeb.CaseLive.Components.CustomerTable do
  @moduledoc false
  use CaseManagerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="customer_cases" rows={@rows} row_click={@row_click}>
        <:col :let={{_id, case}} label={gettext("Title")}>
          {case.title}
        </:col>
        <:col :let={{_id, case}} label={gettext("Priority")}>
          <div class="flex items-center h-full">
            <.risk_badge colour={case.priority} />
          </div>
        </:col>
        <:col :let={{_id, case}} label={gettext("Time Since Updated")}>
          {DateTime.diff(DateTime.utc_now(), case.updated_at, :day)} days
        </:col>
        <:col :let={{_id, case}} label={gettext("ID")}>
          {case.id |> String.slice(1, 7)}
        </:col>
        <:col :let={{_id, case}} label={gettext("Status")}>
          <.status_badge colour={case.status} />
        </:col>
        <:col :let={{_id, case}} label={gettext("Assignee")}>
          {case.assignee_id}
        </:col>
        <:col :let={{_id, case}} label={gettext("Updated?")}>
          <.icon :if={case.updated_since_last?} name="hero-bell-alert" />
        </:col>
      </.table>
    </div>
    """
  end
end
