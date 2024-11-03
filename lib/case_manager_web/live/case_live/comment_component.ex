defmodule CaseManagerWeb.CaseLive.CommentComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  def update(assigns, socket) do
    form =
      CaseManager.Cases.Comment
      |> Form.for_create(:create,
        forms: [
          comment: [
            resource: CaseManager.Cases.Comment,
            create_action: :create,
            actor: assigns[:current_user]
          ]
        ],
        domain: CaseManager.Cases
      )
      |> Form.add_form([:comment])
      |> to_form()

    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:body, "")
     |> assign(:current_user, assigns[:current_user])
     |> assign(:case_id, assigns[:case_id])}
  end

  def handle_event("send", %{"body" => body}, socket) do
    body = body |> html_escape() |> safe_to_string() |> String.replace("\n", "<br/>")

    params =
      %{
        body: body,
        case_id: socket.assigns.case_id,
        user_id: socket.assigns.current_user.id
      }

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _result} ->
        {:noreply, socket |> push_navigate(to: ~p"/case/#{socket.assigns.case_id}")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
