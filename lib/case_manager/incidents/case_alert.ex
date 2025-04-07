defmodule CaseManager.Incidents.CaseAlert do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "case_alerts"
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.Incidents.Case do
      allow_nil? false
    end

    belongs_to :alert, CaseManager.Incidents.Alert do
      allow_nil? false
    end
  end
end
