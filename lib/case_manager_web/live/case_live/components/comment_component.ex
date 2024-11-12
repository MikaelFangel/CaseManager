defmodule CaseManagerWeb.CaseLive.CommentComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form
  alias CaseManager.Cases.Case

  def update(assigns, socket) do
    form =
      Case
      |> Ash.get!(assigns[:case_id])
      |> Form.for_update(:add_comment, forms: [auto?: true], actor: assigns.current_user)
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

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _result} ->
        {:noreply, socket |> push_navigate(to: ~p"/case/#{socket.assigns.case_id}")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
