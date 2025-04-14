defmodule CaseManager.Incidents.CaseAlert do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "case_alerts"
    repo(CaseManager.Repo)
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :case, CaseManager.Incidents.Case do
      primary_key? true
      public? true
      allow_nil? false
    end

    belongs_to :alert, CaseManager.Incidents.Alert do
      primary_key? true
      public? true
      allow_nil? false
    end
  end
end
