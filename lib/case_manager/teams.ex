defmodule CaseManager.Teams do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain

  resources do
    resource CaseManager.Teams.Team
  end
end
