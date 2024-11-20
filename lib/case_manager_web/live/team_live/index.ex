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
      |> assign(:show_create_team_modal, false)
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

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_create_team_modal", _params, socket) do
    form =
      CaseManager.Teams.Team
      |> Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:show_create_team_modal, true)

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

  def handle_event("create_team", %{"form" => params}, socket) do
    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _team} ->
        socket =
          socket
          |> assign(:show_create_team_modal, false)
          |> assign(:pending_refresh?, true)
          |> push_patch(to: ~p"/teams", replace: true)

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> put_flash(:error, gettext("Team creation error."))

        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("hide_create_team_modal", _params, socket) do
    socket =
      socket
      |> assign(:show_create_team_modal, false)

    {:noreply, socket}
  end
end
