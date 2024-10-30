defmodule CaseManagerWeb.CaseLive.Components.MSSPTable do
  @moduledoc false
  use CaseManagerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="mssp_cases" rows={@rows} row_click={@row_click}>
        <:col :let={{_id, case}} label={gettext("Esca.")}>
          <%= if case.escalated do %>
            <.icon name="hero-check-circle" />
          <% else %>
            <.icon name="hero-no-symbol" />
          <% end %>
        </:col>
        <:col :let={{_id, case}} label={gettext("Team")}>
          <%= case.team.name %>
        </:col>
        <:col :let={{_id, case}} label={gettext("Title")}>
          <%= case.title %>
        </:col>
        <:col :let={{_id, case}} label={gettext("Priority")}>
          <.risk_badge colour={case.priority} />
        </:col>
        <:col :let={{_id, case}} label={gettext("Time Since Updated")}>
          <%= DateTime.diff(DateTime.utc_now(), case.updated_at, :day) %> days
        </:col>
        <:col :let={{_id, case}} label={gettext("ID")}>
          <%= case.id |> String.slice(1, 7) %>
        </:col>
        <:col :let={{_id, case}} label={gettext("Status")}>
          <.status_badge colour={case.status} />
        </:col>
        <:col :let={{_id, case}} label={gettext("Assignee")}>
          <%= case.assignee_id %>
        </:col>
      </.table>
    </div>
    """
  end
end
