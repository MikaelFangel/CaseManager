#!/bin/bash

# Don't exit on errors - we want to run all possible seeds
set +e

# Get the script's directory
SCRIPT_DIR="$(dirname "$0")"
SEEDS_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SEEDS_DIR")")")"

# Default to running all seeds if no arguments provided
RUN_ALL=true
CLEAN_ONLY=false

# Function to display usage information
show_usage() {
  echo "Usage: $0 [OPTIONS] [SEED_FILES]"
  echo
  echo "Options:"
  echo "  -h, --help           Show this help message"
  echo "  -c, --clean          Clean the database without seeding"
  echo "  -s, --soc            Run SOC seed (01-socs.exs)"
  echo "  -C, --company        Run Company seed (02-companies.exs)"
  echo "  -u, --user           Run User seed (03-users.exs)"
  echo "  -a, --alert          Run Alert seed (04-alerts.exs)"
  echo "  -i, --incident       Run Case/Incident seed (05-cases.exs)"
  echo "  -r, --relations      Run Case-Alert relations seed (06-case-alert-relations.exs)"
  echo "  -m, --alert-comments Run Alert Comments seed (07-alert-comments.exs)"
  echo "  -S, --user-socs      Run User-SOC relations seed (08-user-soc-relations.exs)"
  echo "  -C, --user-company   Run User-Company relations seed (09-user-company-relations.exs)"
  echo
  echo "Examples:"
  echo "  $0                    Run all seeds in the correct order"
  echo "  $0 -c                 Clean the database without seeding"
  echo "  $0 -s -C              Run only SOC and Company seeds"
  echo
}

# Function to run a seed file and check for errors
run_seed() {
  local seed_file="$1"
  local clean_mode="$2"
  local seed_name=$(basename "$seed_file")
  
  echo "Running $seed_name..."
  if [ "$clean_mode" = "clean" ]; then
    SEED_CLEAN_ONLY=true mix run "$seed_file"
  else
    mix run "$seed_file"
  fi
  
  local result=$?
  if [ $result -eq 0 ]; then
    echo "✅ $seed_name completed successfully"
  else
    echo "⚠️ $seed_name had issues (code $result), but we'll continue with other seeds"
  fi
  echo
  return $result
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -c|--clean)
      CLEAN_ONLY=true
      RUN_ALL=false
      ;;
    -s|--soc)
      RUN_SOC=true
      RUN_ALL=false
      ;;
    -C|--company)
      RUN_COMPANY=true
      RUN_ALL=false
      ;;
    -u|--user)
      RUN_USER=true
      RUN_ALL=false
      ;;
    -a|--alert)
      RUN_ALERT=true
      RUN_ALL=false
      ;;
    -i|--incident)
      RUN_CASE=true
      RUN_ALL=false
      ;;
    -r|--relations)
      RUN_RELATIONS=true
      RUN_ALL=false
      ;;
    -m|--alert-comments)
      RUN_ALERT_COMMENTS=true
      RUN_ALL=false
      ;;
    -S|--user-socs)
      RUN_USER_SOCS=true
      RUN_ALL=false
      ;;
    -C|--user-company)
      RUN_USER_COMPANY=true
      RUN_ALL=false
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      exit 1
      ;;
  esac
  shift
done

cd "$PROJECT_ROOT"

echo "=========================================================="
if [ "$CLEAN_ONLY" = true ]; then
  echo "Cleaning database..."
else
  echo "Running seed files..."
fi
echo "=========================================================="

echo "Project root: $PROJECT_ROOT"
echo "Seeds directory: $SEEDS_DIR"
echo

# Each seed file handles its own dependencies
if [ "$RUN_ALL" = true ] || [ "$CLEAN_ONLY" = true ]; then
# We run in reverse order to ensure dependencies are respected
# For seeding, we need to respect the dependency chain:
# 1. SOCs and companies must exist first
# 2. Then users can be created
# 3. Then alerts and cases can be created referencing the above
# 4. Finally, case-alert relationships can be established
  
  if [ "$CLEAN_ONLY" = true ]; then
    # For cleanup only, we need to delete in reverse dependency order
    # First clean all relations, then cases and alerts, etc.
    echo "Cleaning database in dependency-safe order..."
    run_seed "$SEEDS_DIR/09-user-company-relations.exs" "clean"
    run_seed "$SEEDS_DIR/08-user-soc-relations.exs" "clean"
    run_seed "$SEEDS_DIR/07-alert-comments.exs" "clean"
    run_seed "$SEEDS_DIR/06-case-alert-relations.exs" "clean"
    run_seed "$SEEDS_DIR/05-cases.exs" "clean"
    run_seed "$SEEDS_DIR/04-alerts.exs" "clean"
    run_seed "$SEEDS_DIR/03-users.exs" "clean"
    run_seed "$SEEDS_DIR/02-companies.exs" "clean"
    run_seed "$SEEDS_DIR/01-socs.exs" "clean"
  elif [ "$RUN_ALL" = true ]; then
    # For normal seeding, we create in proper order
    # First create the base records (SOCs, companies)
    run_seed "$SEEDS_DIR/01-socs.exs"
    run_seed "$SEEDS_DIR/02-companies.exs"
    # Then create users
    run_seed "$SEEDS_DIR/03-users.exs"
    # Then create alerts and cases that reference them
    run_seed "$SEEDS_DIR/04-alerts.exs"
    run_seed "$SEEDS_DIR/05-cases.exs"
    # Then create all relationships
    run_seed "$SEEDS_DIR/06-case-alert-relations.exs"
    run_seed "$SEEDS_DIR/07-alert-comments.exs"
    run_seed "$SEEDS_DIR/08-user-soc-relations.exs"
    run_seed "$SEEDS_DIR/09-user-company-relations.exs"
  fi
  
  # Exit early if we're just cleaning
  if [ "$CLEAN_ONLY" = true ]; then
    echo "=========================================================="
    echo "🧹 Database cleaned successfully!"
    echo "=========================================================="
    exit 0
  fi
else
  # Run specific seeds based on flags
  # We'll run these in reverse order from cases to SOCs
  # to make sure dependencies are respected
  if [ "$RUN_SOC" = true ]; then
    run_seed "$SEEDS_DIR/01-socs.exs"
  fi
  
  if [ "$RUN_COMPANY" = true ]; then
    run_seed "$SEEDS_DIR/02-companies.exs"
  fi
  
  if [ "$RUN_USER" = true ]; then
    run_seed "$SEEDS_DIR/03-users.exs"
  fi
  
  if [ "$RUN_ALERT" = true ]; then
    run_seed "$SEEDS_DIR/04-alerts.exs"
  fi
  
  if [ "$RUN_CASE" = true ]; then
    run_seed "$SEEDS_DIR/05-cases.exs"
  fi
  
  if [ "$RUN_RELATIONS" = true ]; then
    run_seed "$SEEDS_DIR/06-case-alert-relations.exs"
  fi
  
  if [ "$RUN_ALERT_COMMENTS" = true ]; then
    run_seed "$SEEDS_DIR/07-alert-comments.exs"
  fi
  
  if [ "$RUN_USER_SOCS" = true ]; then
    run_seed "$SEEDS_DIR/08-user-soc-relations.exs"
  fi
  
  if [ "$RUN_USER_COMPANY" = true ]; then
    run_seed "$SEEDS_DIR/09-user-company-relations.exs"
  fi
fi

echo "=========================================================="
if [ $? -eq 0 ]; then
  echo "🎉 All seed operations completed!"
else
  echo "🎉 Seed operations completed with some issues."
  echo "   Review the output above for any warnings."
fi
echo "=========================================================="