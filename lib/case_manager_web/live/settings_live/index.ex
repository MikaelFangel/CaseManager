defmodule CaseManagerWeb.SettingsLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Configuration
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(current_user: socket.assigns.current_user)
      |> assign(:menu_item, :settings)
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(:background_img, Helpers.load_bg())
      |> allow_upload(:background, accept: :any, max_entries: 1)
      |> allow_upload(:logo, accept: :any, max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_background", _params, socket) do
    Ash.get(Configuration.Setting, "background_img")

    consume_uploaded_entries(socket, :background, fn %{path: path}, entry ->
      file = File.read!(path)

      Configuration.upload_file_to_setting!(
        "background",
        "true",
        %{
          filename: entry.client_name,
          content_type: entry.client_type,
          binary_data: file
        },
        actor: socket.assigns.current_user
      )

      {:ok, "success"}
    end)

    {:noreply, assign(socket, :background_img, Helpers.load_bg())}
  end

  @impl true
  def handle_event("save_logo", _params, socket) do
    Ash.get(Configuration.Setting, "logo_img")

    consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
      file = File.read!(path)

      Configuration.upload_file_to_setting!(
        "logo",
        "true",
        %{
          filename: entry.client_name,
          content_type: entry.client_type,
          binary_data: file
        },
        actor: socket.assigns.current_user
      )

      {:ok, "success"}
    end)

    {:noreply, assign(socket, :logo_img, Helpers.load_logo())}
  end
end
