alias CaseManager.Organizations.SOC

require Ash.Query

SOC
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

socs = [
  %{
    name: "Global Security Operations"
  },
  %{
    name: "CyberDefense Alliance"
  },
  %{
    name: "Sentinel Security Services"
  },
  %{
    name: "BlueTeam Security Operations"
  },
  %{
    name: "Digital Guardian SOC"
  }
]

Ash.bulk_create!(socs, SOC, :create, return_errors?: true, authorize?: false)
