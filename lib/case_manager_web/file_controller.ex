defmodule CaseManagerWeb.FileController do
  use CaseManagerWeb, :controller

  alias CaseManager.ICM.File

  def download(conn, %{"id" => id}) do
    file = Ash.get!(File, id)

    conn
    |> put_resp_content_type("application/octet-stream")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{file.filename}\"")
    |> send_resp(200, file.binary_data)
  end
end
