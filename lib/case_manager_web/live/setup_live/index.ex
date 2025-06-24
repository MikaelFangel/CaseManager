defmodule CaseManagerWeb.SetupLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    soc_form = to_form(CaseManager.Organizations.form_to_create_soc(authorize?: false))
    user_form = to_form(CaseManager.Accounts.form_to_create_user(authorize?: false))

    socket =
      socket
      |> assign(:soc_form, soc_form)
      |> assign(:soc_created, false)
      |> assign(:user_form, user_form)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center w-full h-screen justify-center">
      <div class="space-y-6 w-xl">
        <.form :if={!@soc_created} for={@soc_form} id="soc-form" phx-change="validate_soc" phx-submit="create_soc">
          <div class="mb-6">
            <.input field={@soc_form[:name]} type="text" label="SOC Name" placeholder="Security Operations Center Name" />
          </div>

          <div class="flex justify-end space-x-3">
            <.button type="submit" variant="primary">Create SOC</.button>
          </div>
        </.form>

        <.form :if={@soc_created} for={@user_form} phx-submit="create_user" class="space-y-4">
          <.input field={@user_form[:email]} type="email" label="Email" />
          <.input field={@user_form[:first_name]} type="text" label="First name" />
          <.input field={@user_form[:last_name]} type="text" label="Last name" />
          <.input field={@user_form[:password]} type="password" label="Password" />
          <.input field={@user_form[:password_confirmation]} type="password" label="Password confirmation" />

          <div class="modal-action">
            <.button type="submit" variant="primary">Create User</.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate_soc", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.soc_form, params)
    {:noreply, assign(socket, :soc_form, form)}
  end

  @impl true
  def handle_event("validate_user", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.user_form, params)
    {:noreply, assign(socket, user_form: form)}
  end

  @impl true
  def handle_event("create_soc", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.soc_form, params: params) do
      {:ok, soc} ->
        socket =
          socket |> assign(:soc_created, true) |> assign(:soc, soc) |> put_flash(:info, "SOC created successfully.")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :soc_form, form)}
    end
  end

  @impl true
  def handle_event("create_user", %{"form" => params}, socket) do
    submission_params = %{
      "email" => params["email"],
      "password" => params["password"],
      "password_confirmation" => params["password_confirmation"],
      "first_name" => params["first_name"],
      "last_name" => params["last_name"],
      "socs" => [socket.assigns.soc.id],
      "companies" => []
    }

    case AshPhoenix.Form.submit(socket.assigns.user_form, params: submission_params) do
      {:ok, user} ->
        case CaseManager.Organizations.get_soc_user(user.id, socket.assigns.soc.id) do
          {:ok, soc_user} ->
            CaseManager.Organizations.update_soc_user!(soc_user, %{user_role: :super_admin})

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Failed to update SOC membership")}
        end

        CaseManager.Configuration.set_setting!("initial_setup_complete", "true")
        {:noreply, push_navigate(socket, to: ~p"/")}

      {:error, form} ->
        {:noreply, assign(socket, user_form: form)}
    end
  end
end
