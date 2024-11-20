defmodule CaseManagerWeb.Helpers do
  @moduledoc """
  Module that defines helper function for the web based part of the application.
  """

  @doc """
  Render basic html from text with markdown. All html tags is stripped before returning it as a raw value.
  """
  def render_markdown!(text) do
    text
    |> HtmlSanitizeEx.strip_tags()
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end
end
