defmodule CaseManager.Alerts.Alert do
  use Ash.Resource,
    domain: CaseManager.Alerts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "alerts"
    repo CaseManager.Repo
  end

  actions do
    create :create do
      accept [:alert_id, :title, :risk_level, :start_time, :end_time, :link, :team_id]

      validate fn changeset, _context ->
        team_id = Ash.Changeset.get_attribute(changeset, :team_id)

        if CaseManager.Repo.get(CaseManager.Teams.Team, team_id) do
          :ok
        else
          {:error, "Team not found"}
        end
      end
    end

    read :read do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string do
      allow_nil? false
    end

    attribute :team_id, :uuid do
      allow_nil? false
    end

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :risk_level, :string do
      allow_nil? false
    end

    attribute :start_time, :utc_datetime do
      allow_nil? false
    end

    attribute :end_time, :utc_datetime do
      allow_nil? false
    end

    attribute :link, :string do
      allow_nil? false
    end

    attribute :additional_data, :map
    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      attribute_type :uuid
      attribute_writable? true
      allow_nil? false
    end
  end

  json_api do
    type "alert"
  end
end
