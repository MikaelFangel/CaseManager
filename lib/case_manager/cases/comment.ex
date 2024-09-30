defmodule CaseManager.Cases.Comment do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :case_id, :uuid do
      allow_nil? false
    end

    attribute :user_id, :uuid do
      allow_nil? false
    end

    attribute :body, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "comment"
    repo CaseManager.Repo
  end
end
