defmodule CaseManagerWeb.AuthForm do
  use CaseManagerWeb, :live_component
  use PhoenixHTMLHelpers
  alias AshPhoenix.Form

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(trigger_action: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form))
      |> assign(:trigger_action, form.valid?)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen pr-40 pb-32 place-items-end">
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-trigger-action={@trigger_action}
        phx-target={@myself}
        action={@action}
        class="bg-slate-50 shadow-lg rounded-xl min-w-96 px-8 pt-6 pb-8 mb-4"
        method="POST"
      >
        <h1 class="text-xl font-semibold mb-2"><%= @cta %></h1>
        <hr class="mb-2" />
        <%= if @is_register? do %>
          <fieldset class="form-group">
            <%= label(f, :first_name, "First Name", class: "block text-black text-sm font-bold mb-2") %>
            <%= text_input(f, :first_name,
              class:
                "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:shadow-outline mb-2",
              placeholder: "First Name"
            ) %>
          </fieldset>
          <fieldset class="form-group">
            <%= label(f, :last_name, "Last Name", class: "block text-black text-sm font-bold mb-2") %>
            <%= text_input(f, :last_name,
              class:
                "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:shadow-outline mb-2",
              placeholder: "Last Name"
            ) %>
          </fieldset>
        <% end %>
        <fieldset class="form-group">
          <%= label(f, :email, "Email", class: "block text-black text-sm font-bold mb-2") %>
          <%= text_input(f, :email,
            class:
              "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:shadow-outline mb-2",
            placeholder: "Email",
            type: "email"
          ) %>
        </fieldset>
        <fieldset class="form-group">
          <%= label(f, :password, "Password", class: "block text-black text-sm font-bold mb-2") %>
          <%= text_input(f, :password,
            class:
              "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:shadow-outline mb-2",
            placeholder: "Password",
            type: "password"
          ) %>
        </fieldset>
        <%= if @is_register? do %>
          <fieldset class="form-group">
            <%= label(f, :password_confirmation, "Password Confirmation",
              class: "block text-black text-sm font-bold mb-2"
            ) %>
            <%= text_input(f, :password_confirmation,
              class:
                "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 focus:outline-none focus:shadow-outline mb-2",
              placeholder: "Password Confirmation",
              type: "password"
            ) %>
          </fieldset>
          <fieldset class="form-group">
            <%= label(f, :role, "Role", class: "block text-black text-sm font-bold mb-2") %>
            <%= select(f, :role, ["Analyst", "Admin"],
              class:
                "form-control form-control-lg shadow appearance-none border rounded w-full py-2 px-3 mb-2 focus:outline-none focus:shadow-outline"
            ) %>
          </fieldset>
        <% end %>
        <div class="flex justify-end mt-2">
          <span class="mr-4 mt-2"><a href={@alternative_path}><%= @alternative %></a></span>
          <.button type="submit" class="btn btn-lg bg-slate-950">
            <%= @cta %>
          </.button>
        </div>
      </.form>
    </div>
    """
  end
end
