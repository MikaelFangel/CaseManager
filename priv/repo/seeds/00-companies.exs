alias CaseManager.Organizations.Company

require Ash.Query

Company
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

companies = [
  %{
    name: "Acme Corporation"
  },
  %{
    name: "TechNova Systems"
  },
  %{
    name: "GlobalBank Financial"
  },
  %{
    name: "Quantum Healthcare"
  },
  %{
    name: "EcoSolutions Inc."
  }
]

Ash.bulk_create!(companies, Company, :create, return_errors?: true, authorize?: false)
