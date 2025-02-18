defmodule CaseManager.ICM.CaseView do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "case_views"
    repo CaseManager.Repo
  end

  relationships do
    belongs_to :case, CaseManager.ICM.Case, primary_key?: true, allow_nil?: false, public?: true

    belongs_to :view, CaseManager.ICM.Case.View,
      primary_key?: true,
      allow_nil?: false,
      public?: true
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
