defmodule CaseManager.ContactInfos.IP do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :ip, :string do
      allow_nil? false
    end

    attribute :version, :string
    timestamps()
  end

  postgres do
    table "ip"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  validations do
    validate one_of(:version, ["v4", "v6"])
  end
end
