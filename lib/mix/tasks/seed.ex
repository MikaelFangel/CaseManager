defmodule Mix.Tasks.Seed do
  @moduledoc """
  Seeds the database with test data.

  ## Usage

      mix seed           # Run all seeds in the correct order
      mix seed --clean   # Clean the database without seeding

  ## Options

      --clean, -c        Clean the database without seeding
      --soc, -s          Run SOC seed only
      --company, -C      Run Company seed only  
      --user, -u         Run User seed only
      --alert, -a        Run Alert seed only
      --case, -i         Run Case/Incident seed only
      --help, -h         Show this help message

  ## Examples

      # Run all seeds
      mix seed

      # Clean the database without seeding
      mix seed --clean

      # Run only SOC and Company seeds
      mix seed --soc --company
  """

  use Mix.Task

  @shortdoc "Seeds the database with test data"

  @impl Mix.Task
  def run(args) do
    # Parse command-line arguments
    {opts, _, _} = OptionParser.parse(args, 
      strict: [
        clean: :boolean,
        soc: :boolean,
        company: :boolean,
        user: :boolean,
        alert: :boolean,
        case: :boolean,
        help: :boolean
      ],
      aliases: [
        c: :clean,
        s: :soc,
        C: :company,
        u: :user,
        a: :alert,
        i: :case,
        h: :help
      ]
    )

    cond do
      opts[:help] ->
        # Display help information
        Mix.shell().info(@moduledoc)

      opts[:clean] ->
        # Run clean command
        run_seed_script(["-c"])

      Enum.any?([:soc, :company, :user, :alert, :case], &Keyword.has_key?(opts, &1)) ->
        # Run specific seed files
        args = Enum.reduce([:soc, :company, :user, :alert, :case], [], fn key, acc ->
          case opts[key] do
            true -> acc ++ ["-#{flag_for_key(key)}"]
            _ -> acc
          end
        end)
        run_seed_script(args)

      true ->
        # Run all seeds
        run_seed_script([])
    end
  end

  # Helper to get the flag letter for each seed type
  defp flag_for_key(:soc), do: "s"
  defp flag_for_key(:company), do: "C"
  defp flag_for_key(:user), do: "u"
  defp flag_for_key(:alert), do: "a"
  defp flag_for_key(:case), do: "i"

  # Runs the seed script with the provided arguments
  defp run_seed_script(args) do
    script_path = Path.join([File.cwd!(), "priv", "repo", "seeds", "scripts", "run_seeds.sh"])

    # Ensure script is executable
    File.chmod(script_path, 0o755)

    # Build command with arguments
    cmd = [script_path] ++ args
    
    # Execute the script
    {output, exit_code} = System.cmd("bash", cmd, stderr_to_stdout: true)
    
    # Display the output
    Mix.shell().info(output)
    
    # Exit with the same exit code as the script
    if exit_code != 0 do
      Mix.shell().info("Seed script completed with exit code #{exit_code}")
    end
  end
end