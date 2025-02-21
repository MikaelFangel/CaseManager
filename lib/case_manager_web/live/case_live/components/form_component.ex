defmodule CaseManagerWeb.CaseLive.FormComponent do
  @moduledoc false
  use CaseManagerWeb, :live_component

  alias AshPhoenix.Form
  alias CaseManager.ICM

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:action, assigns[:action])
      |> assign(:current_user, assigns[:current_user])
      |> assign(:team_name, assigns[:team_name])
      |> assign(:related_alerts, assigns[:related_alerts])
      |> assign(:files, assigns[:files] || [])
      |> assign(:form, assigns[:form])
      |> assign(:on_cancel, assigns[:on_cancel])
      |> assign(:uploaded_files, [])
      |> allow_upload(:attachments, accept: :any, max_entries: 10)
      |> assign(:alert, nil)
      |> assign(:alert_id, nil)

    {:ok, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    related_alert_ids = Enum.map(socket.assigns.related_alerts, fn {_id, alert} -> alert.id end)

    params =
      params
      |> Map.put(:alert, related_alert_ids)
      |> Map.delete(:uploaded_files)
      |> then(&if(socket.assigns[:action] == :new, do: %{case: &1}, else: &1))

    upload_attachments = fn case ->
      consume_uploaded_entries(socket, :attachments, fn %{path: path}, entry ->
        file = File.read!(path)

        ICM.upload_file_to_case!(
          case,
          %{filename: Path.basename(entry.client_name), content_type: entry.client_type, binary_data: file},
          actor: socket.assigns.current_user
        )

        {:ok, "success"}
      end)
    end

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, %{case: [case]}} ->
        upload_attachments.(case)

        {:noreply,
         socket
         |> put_flash(:info, gettext("Case created successfully."))
         |> push_navigate(to: ~p"/case/#{case.id}")}

      {:ok, case} ->
        upload_attachments.(case)

        {:noreply,
         socket
         |> put_flash(:info, gettext("Case updated successfully."))
         |> push_navigate(to: ~p"/case/#{case.id}")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("show_modal", %{"alert_id" => alert_id}, socket) do
    alert = ICM.get_alert_by_id!(alert_id)
    socket = assign(socket, :alert, alert)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    socket = assign(socket, :alert, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_confirmation_modal", %{"alert_id" => alert_id}, socket) do
    socket = assign(socket, :alert_id, alert_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_confirmation_modal", _params, socket) do
    socket = assign(socket, :alert_id, nil)

    {:noreply, socket}
  end
end
