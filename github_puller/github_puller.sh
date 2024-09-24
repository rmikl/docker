#!/bin/bash

# Check if required environment variables are set
if [ -z "$GITPULLER_REPO_PATH" ]; then
  echo "Environment variable GITPULLER_REPO_PATH is not set."
  exit 1
fi

if [ -z "$GITPULLER_REPO_URL" ]; then
  echo "Environment variable GITPULLER_REPO_URL is not set. Please provide the Git repository URL."
  exit 1
fi

if [ -z "$SLEEP_TIME" ]; then
  echo "Environment variable SLEEP_TIME is not set. Using default value of 60 seconds."
  SLEEP_TIME=60
fi

if [ -z "$GITPULLER_BRANCH" ]; then
  echo "Environment variable GITPULLER_BRANCH is not set. Using 'main' as default branch."
  GITPULLER_BRANCH="main"
fi

# Variable for the number of pull attempts before giving up
PULL_ATTEMPTS=${PULL_ATTEMPTS:-3}

# Function to clone the repository if not already present
clone_repository() {
  if [ ! -d "$GITPULLER_REPO_PATH/.git" ]; then
    echo "Directory $GITPULLER_REPO_PATH does not exist or is not a Git repository. Cloning the repository..."
    git clone "$GITPULLER_REPO_URL" "$GITPULLER_REPO_PATH"
    
    if [ $? -ne 0 ]; then
      echo "Error while cloning the repository from $GITPULLER_REPO_URL. Exiting."
      exit 1
    fi

    cd "$GITPULLER_REPO_PATH" || { echo "Cannot navigate to the repository directory"; exit 1; }
    
    # Switch to the desired branch
    git checkout "$GITPULLER_BRANCH"
    
    if [ $? -ne 0 ]; then
      echo "Error while checking out branch $GITPULLER_BRANCH. Exiting."
      exit 1
    fi

    echo "Repository cloned and switched to branch $GITPULLER_BRANCH."
  else
    echo "Repository already exists at $GITPULLER_REPO_PATH."
  fi
}

# Function to pull changes from the repository
pull_changes() {
  cd "$GITPULLER_REPO_PATH" || { echo "Cannot navigate to the repository directory"; exit 1; }

  # Attempt to pull changes from the specified branch
  git pull origin "$GITPULLER_BRANCH"
  PULL_EXIT_CODE=$?

  if [ $PULL_EXIT_CODE -eq 0 ]; then
    echo "Successfully pulled changes from $GITPULLER_BRANCH."
  else
    echo "Error occurred while pulling changes from $GITPULLER_BRANCH."
    
    # Check for merge conflicts
    if git status | grep -q "Unmerged paths"; then
      echo "Merge conflict detected. Exiting script with error code 1."
      exit 1
    else
      echo "Other git pull error. Exit code: $PULL_EXIT_CODE"
    fi
  fi
}

# Clone the repository if it does not already exist
clone_repository

# Main loop controlled by the environment variable
while true; do
  echo "Checking for updates in the repository on branch $GITPULLER_BRANCH..."

  # Call the function to pull changes
  pull_changes

  date  
  # Sleep for the time specified in the environment variable
  echo "Sleeping for $SLEEP_TIME seconds..."
  sleep "$SLEEP_TIME"
done