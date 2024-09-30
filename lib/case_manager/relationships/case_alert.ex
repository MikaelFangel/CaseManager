defmodule CaseManager.Relationships.CaseAlert do
  @moduledoc """
  Resource for the many-to-many relationship between cases and alerts.
  """
  use Ash.Resource,
    domain: nil,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "case_alert"
    repo CaseManager.Repo
  end

  relationships do
    belongs_to :case, CaseManager.Cases.Case, primary_key?: true, allow_nil?: false
    belongs_to :alert, CaseManager.Alerts.Alert, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
