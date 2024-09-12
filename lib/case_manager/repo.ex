defmodule CaseManager.Repo do
  use AshPostgres.Repo, otp_app: :case_manager

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
