defmodule CaseManager.Repo do
  use AshPostgres.Repo, otp_app: :case_manager

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext", "pg_trgm"]
  end

  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
