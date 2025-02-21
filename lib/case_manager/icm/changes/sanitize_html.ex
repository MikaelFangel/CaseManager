defmodule CaseManager.Changes.SanitizeHtml do
  @moduledoc false
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom!"}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.fetch_change(changeset, opts[:attribute]) do
      {:ok, new_value} ->
        text = HtmlSanitizeEx.strip_tags(new_value)
        Ash.Changeset.force_change_attribute(changeset, opts[:attribute], text)

      :error ->
        changeset
    end
  end
end
