defmodule CaseManager.ContactInfos.Email do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "email"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
