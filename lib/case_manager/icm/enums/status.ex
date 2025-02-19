defmodule CaseManager.ICM.Enums.Status do
  @moduledoc false
  use Ash.Type.Enum, values: [:in_progress, :pending, :t_positive, :f_positive, :benign]
end
