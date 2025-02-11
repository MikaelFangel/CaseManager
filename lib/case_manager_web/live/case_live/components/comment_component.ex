defmodule CaseManagerWeb.CaseLive.CommentComponent do
  @moduledoc false
  use CaseManagerWeb, :live_component

  alias AshPhoenix.Form
  alias CaseManager.ICM

  def update(assigns, socket) do
    form =
      assigns[:case_id]
      |> ICM.get_case_by_id!(actor: assigns[:current_user])
      |> ICM.form_to_add_comment_to_case(actor: assigns[:current_user])
      |> to_form()

    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:body, "")
     |> assign(:current_user, assigns[:current_user])
     |> assign(:case_id, assigns[:case_id])}
  end

  def handle_event("send", %{"body" => body}, socket) do
    params = %{body: HtmlSanitizeEx.strip_tags(body)}

    action_opts = [actor: socket.assigns.current_user]

    case Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _result} ->
        {:noreply, push_navigate(socket, to: ~p"/case/#{socket.assigns.case_id}")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
