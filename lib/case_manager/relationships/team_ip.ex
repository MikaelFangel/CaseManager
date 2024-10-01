defmodule CaseManager.Relationships.TeamIP do
  @moduledoc """
  Resource for the many-to-many relationship between teams and ips.
  """
  use Ash.Resource,
    domain: nil,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "team_ip"
    repo CaseManager.Repo
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team, primary_key?: true, allow_nil?: false
    belongs_to :ip, CaseManager.ContactInfos.IP, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
