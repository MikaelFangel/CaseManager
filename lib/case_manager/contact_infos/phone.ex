defmodule CaseManager.ContactInfos.Phone do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :country_code, :string

    attribute :phone, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "phone"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
