defmodule CaseManagerWeb.SettingsLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.AppConfig.Setting

  @impl true
  def mount(_params, _session, socket) do
    background_img =
      case Ash.get(Setting, %{key: "background"}) do
        {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
        {:error, _error} -> nil
      end

    logo_img =
      case Ash.get(Setting, %{key: "logo"}) do
        {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
        {:error, _error} -> nil
      end

    socket =
      socket
      |> assign(current_user: socket.assigns.current_user)
      |> assign(:menu_item, :settings)
      |> assign(:uploaded_files, [])
      |> allow_upload(:background, accept: :any, max_entries: 1)
      |> allow_upload(:logo, accept: :any, max_entries: 1)
      |> assign(:background_img, background_img)
      |> assign(:logo_img, logo_img)

    {:ok, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_background", _params, socket) do
    Ash.get(CaseManager.AppConfig.Setting, "background_img")

    uploaded_files =
      consume_uploaded_entries(socket, :background, fn %{path: path}, entry ->
        file = File.read!(path)

        Setting.upload_file!(
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

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  @impl true
  def handle_event("save_logo", _params, socket) do
    Ash.get(CaseManager.AppConfig.Setting, "logo_img")

    uploaded_files =
      consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
        file = File.read!(path)

        Setting.upload_file!(
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

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end
end
