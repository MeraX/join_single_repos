# Anemoi Repository Migration Guide

## Overview 
We are consolidating our training, model, and graphs repositories into a single mono-repository called Anemoi Core to improve code organization and development workflows. This document outlines how to smoothly transition your work to the new repository. 

## Key Points 
* **Continuous Development**: This migration should not block your ongoing work. Continue development in your current repository until you're ready to migrate. 
* **Current State**: The new mono-repository contains the latest state of all individual components, serving as your migration target. 
* **Flexible Timeline**: Each developer can migrate their work according to their own schedule. The migration process is designed to be self-paced. 
* **Repository Access**: The original repositories will remain accessible in read-only mode, ensuring no historical information is lost. 

## Migration Process 

### Branch Migration 
We provide scripts to help transfer your branches: 
https://github.com/MeraX/join_single_repos

### Steps

1. **Clone the new repo**
```bash
git clone https://github.com/ecmwf/anemoi-core
```

2. **Add the Remote**  
You can decide if you want to add the ecmwf remote, a private remote, or a local remote:
```bash
git remote add anemoi-training https://github.com/ecmwf/anemoi-training
```
Or
```bash
git remote add anemoi-training ~/my_anemoi_dev/anemoi-training
```

3. **Run the migration script for your branch**  
There is one assumption of these scripts: Git subtree must be available on your system. These should be in the git-core, but might not be installed as they're part of git-contrib. On ATOS they're available through the git module now.

We provided two options:

**Option A: Python Script**  
Requires GitPython (`pip install GitPython`)  
[Script location](https://github.com/MeraX/join_single_repos/blob/main/git-subtree-scripts.py)
```bash
python git-subtree-scripts.py training my_feature_in_training
```

**Option B: Bash Script**  
[Script location](https://github.com/MeraX/join_single_repos/blob/main/merge_feature_branch.sh)
```bash
./merge_feature_branch.sh
```
