defmodule CaseManager.AppConfig.Setting do
  @moduledoc """
  Resource used to store application wide settings in a persitent manner.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.AppConfig,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("setting")
    repo(CaseManager.Repo)
  end

  attributes do
    attribute :key, :string do
      allow_nil? false
      primary_key? true
      public? true
    end

    attribute :value, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :set_setting do
      argument :key, :string, allow_nil?: false
      argument :value, :string, allow_nil?: false

      upsert? true
      upsert_identity :key

      change set_attribute(:key, arg(:key))
      change set_attribute(:value, arg(:value))
    end
  end

  code_interface do
    define :set_setting, args: [:key, :value]
  end

  identities do
    identity :key, [:key]
  end
end
