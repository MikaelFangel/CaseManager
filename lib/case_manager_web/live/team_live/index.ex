defmodule CaseManagerWeb.TeamLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(:menu_item, :teams)
      |> assign(:selected_team, nil)
      |> assign(:show_form_modal, false)
      |> assign(:pending_refresh?, false)
      |> assign(:team_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query_text = Map.get(params, "q", "")

    page = Teams.search_teams!(query_text, load: [:email, :phone, :ip])
    teams = page.results

    socket =
      socket
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_teams?, page.more?)
      |> assign(:search, query_text)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    params = remove_empty(%{q: search})
    {:noreply, push_patch(socket, to: ~p"/teams/?#{params}")}
  end

  @impl true
  def handle_event("load_more_teams", _params, socket) do
    page = Ash.page!(socket.assigns.page, :next)
    teams = socket.assigns.teams ++ page.results

    socket =
      socket
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_teams?, page.more?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_teams", _params, socket) do
    page = Teams.list_teams_paged!(load: [:email, :phone, :ip])
    teams = page.results

    socket =
      socket
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_teams?, page.more?)
      |> assign(:pending_refresh?, false)
      |> assign(:selected_team, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_team", %{"team_id" => team_id}, socket) do
    team =
      Teams.get_team_by_id!(team_id,
        load: [
          :alert_with_cases_count,
          :alert_without_cases_count,
          :alert_info_count,
          :alert_low_count,
          :alert_medium_count,
          :alert_high_count,
          :alert_critical_count,
          :case_in_progress_count,
          :case_pending_count,
          :case_t_positive_count,
          :case_f_positive_count,
          :case_benign_count,
          :case_info_count,
          :case_low_count,
          :case_medium_count,
          :case_high_count,
          :case_critical_count
        ]
      )

    socket = assign(socket, :selected_team, team)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_team", %{"team_id" => team_id}, socket) do
    socket =
      case Teams.get_team_by_id(team_id) do
        {:ok, team} ->
          Ash.destroy!(team)
          assign(socket, :pending_refresh?, true)

        {:error, _error} ->
          put_flash(socket, :error, gettext("Team already deleted"))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_form_modal", %{"team_id" => team_id}, socket) do
    team_id
    |> Teams.get_team_by_id!(load: [:email, :phone, :ip])
    |> Form.for_update(:update, forms: [auto?: true])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("show_form_modal", _params, socket) do
    Team
    |> Form.for_create(:create, forms: [auto?: true])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("add_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, path, type: :create)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("remove_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit_team_form", %{"form" => params}, socket) do
    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _team} ->
        socket =
          socket
          |> assign(:show_form_modal, false)
          |> assign(:pending_refresh?, true)
          |> push_patch(to: ~p"/teams", replace: true)

        {:noreply, socket}

      {:error, form} ->
        socket = put_flash(socket, :error, gettext("Team save error."))

        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("hide_form_modal", _params, socket) do
    socket = assign(socket, :show_form_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_confirmation_modal", %{"team_id" => team_id}, socket) do
    socket = assign(socket, :team_id, team_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_confirmation_modal", _params, socket) do
    socket = assign(socket, :team_id, nil)

    {:noreply, socket}
  end

  defp set_form_for_modal(form, socket) do
    form = to_form(form)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:show_form_modal, true)

    {:noreply, socket}
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
  end
end
