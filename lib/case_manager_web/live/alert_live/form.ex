defmodule CaseManagerWeb.AlertLive.Form do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents
  alias CaseManager.Incidents.Alert

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage alert records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="alert-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Alert</.button>
          <.button navigate={return_path(@return_to, @alert)}>Cancel</.button>
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
    alert = Incidents.get_alert!(id)

    socket
    |> assign(:page_title, "Edit Alert")
    |> assign(:alert, alert)
    |> assign(:form, to_form(Incidents.form_to_update_alert(alert)))
  end

  defp apply_action(socket, :new, _params) do
    alert = %Alert{}

    socket
    |> assign(:page_title, "New Alert")
    |> assign(:alert, alert)
    |> assign(:form, to_form(Incidents.form_to_update_alert(alert)))
  end

  @impl true
  def handle_event("validate", %{"alert" => alert_params}, socket) do
    changeset = Incidents.update_alert(socket.assigns.alert, alert_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"alert" => alert_params}, socket) do
    save_alert(socket, socket.assigns.live_action, alert_params)
  end

  defp save_alert(socket, :edit, alert_params) do
    case Incidents.update_alert(socket.assigns.alert, alert_params) do
      {:ok, alert} ->
        {:noreply,
         socket
         |> put_flash(:info, "Alert updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, alert))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_alert(socket, :new, alert_params) do
    case Incidents.create_alert(alert_params) do
      {:ok, alert} ->
        {:noreply,
         socket
         |> put_flash(:info, "Alert created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, alert))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _alert), do: ~p"/alert"
  defp return_path("show", alert), do: ~p"/alert/#{alert}"
end
