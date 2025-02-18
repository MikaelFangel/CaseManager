defmodule CaseManager.ICM.CaseAlert do
  @moduledoc """
  Resource for the many-to-many relationship between cases and alerts.
  """
  use Ash.Resource,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "case_alert"
    repo CaseManager.Repo

    references do
      reference :alert, on_delete: :delete, on_update: :update, name: "case_alert_to_alert_fkey"
      reference :case, on_delete: :delete, on_update: :update, name: "case_alert_to_case_fkey"
    end
  end

  relationships do
    belongs_to :case, CaseManager.ICM.Case, primary_key?: true, allow_nil?: false, public?: true

    belongs_to :alert, CaseManager.ICM.Alert,
      primary_key?: true,
      allow_nil?: false,
      public?: true
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
