import argparse
from git import Repo, GitCommandError
from pathlib import Path
import sys

"""
# merge branch "my_feature_in_training" of repo "anemoi-training"
1)
    git clone https://github.com/ecmwf/anemoi-core
2a)
    git remote add anemoi-training https://github.com/ecmwf/anemoi-training
2b)
    git remote add anemoi-training ~/my_anemoi_dev/anemoi-training
3)
    python git-subtree-scripts.py training my_feature_in_training
"""

def check_remotes(repo: Repo, package_suffix: str) -> bool:
    """
    Ensures the subtree remote exists and is set up properly.
    
    Args:
        repo: GitPython Repo object
        package_suffix: Suffix of the package name (e.g., 'training' for 'anemoi-training')
    """
    package_name = f"anemoi-{package_suffix}"
    repo_url = f"https://github.com/ecmwf/{package_name}.git"
    prefix = f"packages/{package_name}"
    
    # Add the remote if it doesn't exist
    try:
        remote = repo.remote(package_name)
        print(f"Remote {package_name} already exists")
    except ValueError:
        print(f"Please add your remote for {package_name}. E.g.:")
        print(f" git remote add {package_name} https://github.com/ecmwf/{package_name}")
        print(f" git remote add {package_name} ~/my_anemoi_dev/{package_name}")
        sys.exit(2)
    
    # Fetch the remote
    print(f"Fetching {package_name}")
    remote.fetch()
    

def port_branch(package_suffix: str, branch_name: str):
    """
    Port a branch from the original Anemoi repository to the monorepo.
    Sets up the subtree if needed.
    
    Args:
        package_suffix: Suffix of the package name (e.g., 'training' for 'anemoi-training')
        branch_name: Name of the branch to port
    """
    package_name = f"anemoi-{package_suffix}"
    prefix = f"{package_suffix}/"
    mono_branch = f"{package_suffix}_{branch_name}"
    
    try:
        # Open the repository
        repo = Repo('.')
        
        # Verify we're in a git repository
        if not repo.git_dir:
            print("Error: Not in a git repository root directory")
            sys.exit(1)
        
        # Ensure subtree is set up
        setup_needed = check_remotes(repo, package_suffix)
        
        # Create and checkout new branch
        print(f"Creating new branch: {mono_branch}")
        current = repo.active_branch
        try:
            new_branch = repo.create_head(mono_branch)
            new_branch.checkout()
        except GitCommandError as e:
            if "already exists" in str(e):
                print(f"Branch {mono_branch} already exists. Checking it out.")
                repo.heads[mono_branch].checkout()
            else:
                raise
        
        # Get the remote (should exist now)
        remote = repo.remote(package_name)
        
        # Fetch the remote branch
        print(f"Fetching branch {branch_name} from {package_name}")
        remote.fetch(branch_name)
        
        # Pull the changes using subtree, preserving history
        print(f"Pulling changes into subtree")
        try:
            repo.git.execute(['git', 'subtree', 'pull', f'--prefix={prefix}', 
                            package_name, branch_name])
            print(f"Successfully ported branch {branch_name}")
        except GitCommandError as e:
            print(f"Error pulling subtree changes: {str(e)}")
            # Cleanup and return to original branch
            current.checkout()
            repo.delete_head(mono_branch, force=True)
            sys.exit(1)
            
    except GitCommandError as e:
        print(f"Git error occurred: {str(e)}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Port a branch from original Anemoi repository to monorepo")
    parser.add_argument("package_suffix", help="Suffix of the package name (e.g., 'training' for 'anemoi-training')", choices=["training", "models", "graphs"])
    parser.add_argument("branch_name", help="Name of the branch to port")
    
    args = parser.parse_args()

    port_branch(args.package_suffix, args.branch_name)

if __name__ == "__main__":
    main()

