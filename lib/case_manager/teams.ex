defmodule CaseManager.Teams do
  use Ash.Domain

  resources do
    resource CaseManager.Teams.Team
  end
end
