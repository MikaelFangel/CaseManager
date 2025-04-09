defmodule CaseManagerWeb.UserLive.Form do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Accounts
  alias CaseManager.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} type="text" label="Email" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save User</.button>
          <.button navigate={return_path(@return_to, @user)}>Cancel</.button>
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
    user = Accounts.get_user!(id)

    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
  end

  defp apply_action(socket, :new, _params) do
    user = %User{}

    socket
    |> assign(:page_title, "New User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _user), do: ~p"/user"
  defp return_path("show", user), do: ~p"/user/#{user}"
end
