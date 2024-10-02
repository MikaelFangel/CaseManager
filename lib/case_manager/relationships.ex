defmodule CaseManager.Relationships do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain
  alias CaseManager.Relationships.{CaseAlert, TeamEmail, TeamIP, TeamPhone}

  resources do
    resource CaseAlert
    resource TeamIP
    resource TeamEmail
    resource TeamPhone
  end
end
