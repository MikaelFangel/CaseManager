defmodule CaseManagerWeb.CaseLive.Form do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash}>
      <:top>
        <.header>
          {@page_title}
        </.header>
      </:top>

      <:left>
        <.form for={@form} id="case-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} type="text" label="Title" placeholder="Multiple accounts added to security group" />
          <.input field={@form[:status]} type="select" label="Status" options={CaseManager.Incidents.CaseStatus.values() |> Enum.map(&{&1, &1})} />
          <.input field={@form[:severity]} type="select" label="Severity" options={CaseManager.Incidents.Severity.values() |> Enum.map(&{&1, &1})} />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Case</.button>
            <.button navigate={return_path(@return_to, @case)}>Cancel</.button>
          </footer>
        </.form>
      </:left>
      <:right></:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_other), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)
    case = Incidents.get_case!(id, actor: user)

    socket
    |> assign(:page_title, "Edit Case")
    |> assign(:case, case)
    |> assign(:form, to_form(Incidents.form_to_update_case(case, actor: user)))
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _case} ->
        socket =
          socket
          |> put_flash(:info, "Case updated successfully.")
          |> push_navigate(to: return_path("show", socket.assigns.case))

        {:noreply, socket}

      {:error, form} ->
        socket = assign(socket, :form, form)
        {:noreply, socket}
    end
  end

  defp return_path("index", _case), do: ~p"/case"
  defp return_path("show", case), do: ~p"/case/#{case}"
end
