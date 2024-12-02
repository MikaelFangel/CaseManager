defmodule CaseManagerWeb.ConfirmationModal do
  @moduledoc """
  Provides a modal prompting the user for a confirmation of an action.
  """

  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  import CaseManagerWeb.Button
  import CaseManagerWeb.Header
  import CaseManagerWeb.ModalTemplate

  alias Phoenix.LiveView.JS

  attr :id, :string, default: "confirmation_modal"
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_action, JS, default: %JS{}
  attr :action_btn_txt, :string, required: true, doc: "verb confirming the action"
  attr :title, :string, required: true, doc: "a <verb + noun>? describing what action the user is confirming"

  attr :body, :string,
    default: gettext("This can't be undone"),
    doc: "concise text informing the user that the action is irreversible"

  def confirmation_modal(assigns) do
    ~H"""
    <.modal_template id={@id} show={@show} on_cancel={@on_cancel}>
      <.header class="flex-none font-bold"><%= @title %></.header>
      <hr class="border-t border-gray-300 mt-1 mb-2.5" />

      <span>
        <%= @body %>
      </span>

      <br />
      <div class="flex justify-end space-x-2">
        <.button phx-click={@on_cancel}>
          <%= gettext("Cancel") %>
        </.button>
        <%= if @action_btn_txt do %>
          <.button colour={:critical} phx-click={@on_action}>
            <%= @action_btn_txt %>
          </.button>
        <% end %>
      </div>
    </.modal_template>
    """
  end
end
