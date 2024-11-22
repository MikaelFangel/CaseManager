defmodule CaseManagerWeb.TeamLive.Index do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form
  alias CaseManager.Teams.Team

  @impl true
  def mount(_params, _session, socket) do
    page = Team.read_by_name_asc!(load: [:email, :phone, :ip])
    teams = page.results

    socket =
      socket
      |> assign(:menu_item, :teams)
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)
      |> assign(:selected_team, nil)
      |> assign(:show_form_modal, false)
      |> assign(:pending_refresh?, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more_teams", _params, socket) do
    page = Ash.page!(socket.assigns.page, :next)
    teams = socket.assigns.teams ++ page.results

    socket =
      socket
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_teams", _params, socket) do
    page = Team.read_by_name_asc!(load: [:email, :phone, :ip])
    teams = page.results

    socket =
      socket
      |> assign(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)
      |> assign(:pending_refresh?, false)
      |> assign(:selected_team, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_team", %{"team_id" => team_id}, socket) do
    team =
      Ash.get!(CaseManager.Teams.Team, team_id,
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

    IO.inspect(team, label: "Team")

    socket =
      socket
      |> assign(:selected_team, team)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_team", %{"team_id" => team_id}, socket) do
    team = Ash.get!(CaseManager.Teams.Team, team_id)
    Ash.destroy!(team)

    socket =
      socket
      |> assign(:pending_refresh?, true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_form_modal", %{"team_id" => team_id}, socket) do
    form =
      Ash.get!(CaseManager.Teams.Team, team_id, load: [:email, :phone, :ip])
      |> Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    IO.inspect(form, label: "Update form")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:show_form_modal, true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_form_modal", _params, socket) do
    form =
      CaseManager.Teams.Team
      |> Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:show_form_modal, true)

    {:noreply, socket}
  end

  def handle_event("add_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, path, type: :create)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("remove_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

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
        socket =
          socket
          |> put_flash(:error, gettext("Team save error."))

        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("hide_form_modal", _params, socket) do
    socket =
      socket
      |> assign(:show_form_modal, false)

    {:noreply, socket}
  end
end
