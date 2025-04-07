defmodule CaseManagerWeb.CaseLive.Form do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents
  alias CaseManager.Incidents.Case

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage case records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="case-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Case</.button>
          <.button navigate={return_path(@return_to, @case)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
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
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    case = Incidents.get_case!(id)

    socket
    |> assign(:page_title, "Edit Case")
    |> assign(:case, case)
    |> assign(:form, to_form(Incidents.update_case(case)))
  end

  defp apply_action(socket, :new, _params) do
    case = %Case{}

    socket
    |> assign(:page_title, "New Case")
    |> assign(:case, case)
    |> assign(:form, to_form(Incidents.update_case(case)))
  end

  @impl true
  def handle_event("validate", %{"case" => case_params}, socket) do
    changeset = Incidents.update_case(socket.assigns.case, case_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"case" => case_params}, socket) do
    save_case(socket, socket.assigns.live_action, case_params)
  end

  defp save_case(socket, :edit, case_params) do
    case Incidents.update_case(socket.assigns.case, case_params) do
      {:ok, case} ->
        {:noreply,
         socket
         |> put_flash(:info, "Case updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, case))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_case(socket, :new, case_params) do
    case Incidents.create_case(case_params) do
      {:ok, case} ->
        {:noreply,
         socket
         |> put_flash(:info, "Case created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, case))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _case), do: ~p"/cases"
  defp return_path("show", case), do: ~p"/cases/#{case}"
end
