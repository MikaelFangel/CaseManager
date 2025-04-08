defmodule CaseManagerWeb.DataDisplay do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  @doc """
  Renders a status indicator

  ## Examples

      <.status type="info" />
      <.status type="error" animation="bounce" />
  """

  attr :type, :atom,
    values: [:primary, :secondary, :accent, :neutral, :info, :success, :warning, :error, nil],
    default: nil

  attr :animation, :atom, values: [:ping, :bounce, nil], default: nil
  attr :rest, :global

  def status(%{type: nil, animation: nil} = assigns) do
    ~H"""
    <div aria-label="status" class="status" {@rest} />
    """
  end

  def status(%{type: nil, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="status" class="status animate-ping" {@rest} />
    """
  end

  def status(%{type: nil, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="status" class="status animate-bounce" {@rest} />
    """
  end

  def status(%{type: :primary, animation: nil} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-primary" {@rest} />
    """
  end

  def status(%{type: :primary, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-primary animate-ping" {@rest} />
    """
  end

  def status(%{type: :primary, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-primary animate-bounce" {@rest} />
    """
  end

  def status(%{type: :secondary, animation: nil} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-secondary" {@rest} />
    """
  end

  def status(%{type: :secondary, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-secondary animate-ping" {@rest} />
    """
  end

  def status(%{type: :secondary, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-secondary animate-bounce" {@rest} />
    """
  end

  def status(%{type: :accent, animation: nil} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-accent" {@rest} />
    """
  end

  def status(%{type: :accent, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-accent animate-ping" {@rest} />
    """
  end

  def status(%{type: :accent, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-accent animate-bounce" {@rest} />
    """
  end

  def status(%{type: :neutral, animation: nil} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-neutral" {@rest} />
    """
  end

  def status(%{type: :neutral, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-neutral animate-ping" {@rest} />
    """
  end

  def status(%{type: :neutral, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="status" class="status status-neutral animate-bounce" {@rest} />
    """
  end

  def status(%{type: :info, animation: nil} = assigns) do
    ~H"""
    <div aria-label="info" class="status status-info" {@rest} />
    """
  end

  def status(%{type: :info, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="info" class="status status-info animate-ping" {@rest} />
    """
  end

  def status(%{type: :info, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="info" class="status status-info animate-bounce" {@rest} />
    """
  end

  def status(%{type: :success, animation: nil} = assigns) do
    ~H"""
    <div aria-label="success" class="status status-success" {@rest} />
    """
  end

  def status(%{type: :success, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="success" class="status status-success animate-ping" {@rest} />
    """
  end

  def status(%{type: :success, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="success" class="status status-success animate-bounce" {@rest} />
    """
  end

  def status(%{type: :warning, animation: nil} = assigns) do
    ~H"""
    <div aria-label="warning" class="status status-warning" {@rest} />
    """
  end

  def status(%{type: :warning, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="warning" class="status status-warning animate-ping" {@rest} />
    """
  end

  def status(%{type: :warning, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="warning" class="status status-warning animate-bounce" {@rest} />
    """
  end

  def status(%{type: :error, animation: nil} = assigns) do
    ~H"""
    <div aria-label="error" class="status status-error" {@rest} />
    """
  end

  def status(%{type: :error, animation: :ping} = assigns) do
    ~H"""
    <div aria-label="error" class="status status-error animate-ping" {@rest} />
    """
  end

  def status(%{type: :error, animation: :bounce} = assigns) do
    ~H"""
    <div aria-label="error" class="status status-error animate-bounce" {@rest} />
    """
  end

  @doc """
  Renders a badge

  ## Examples

      <.badge type="success">Success</.badge>
      <.badge type="error">Error</.badge>
  """

  attr :type, :atom,
    values: [:primary, :secondary, :accent, :neutral, :info, :success, :warning, :error, nil],
    default: nil

  attr :modifier, :atom, values: [:dash, :outline, :soft, :ghost, nil], default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block

  def badge(%{type: nil, modifier: nil} = assigns) do
    ~H"""
    <div class="badge" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :primary, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-primary" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :secondary, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-secondary" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :accent, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-accent" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :neutral, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-neutral" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :info, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-info" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :success, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-success" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :warning, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-warning" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :error, modifier: nil} = assigns) do
    ~H"""
    <div class="badge badge-error" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: nil, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: nil, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: nil, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: nil, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :primary, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-primary badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :primary, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-primary badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :primary, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-primary badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :primary, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-primary badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :secondary, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-secondary badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :secondary, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-secondary badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :secondary, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-secondary badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :secondary, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-secondary badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :accent, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-accent badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :accent, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-accent badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :accent, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-accent badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :accent, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-accent badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :neutral, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-neutral badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :neutral, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-neutral badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :neutral, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-neutral badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :neutral, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-neutral badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :info, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-info badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :info, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-info badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :info, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-info badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :info, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-info badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :success, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-success badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :success, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-success badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :success, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-success badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :success, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-success badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :warning, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-warning badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :warning, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-warning badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :warning, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-warning badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :warning, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-warning badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :error, modifier: :outline} = assigns) do
    ~H"""
    <div class="badge badge-error badge-outline" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :error, modifier: :dash} = assigns) do
    ~H"""
    <div class="badge badge-error badge-dash" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :error, modifier: :soft} = assigns) do
    ~H"""
    <div class="badge badge-error badge-soft" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def badge(%{type: :error, modifier: :ghost} = assigns) do
    ~H"""
    <div class="badge badge-error badge-ghost" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
