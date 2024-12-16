#!/bin/bash
set -ex

## Needs the Github CLI tool installed

for repo in training models graphs; do
    echo "Processing issues from ecmwf/anemoi-$repo..."
    
    gh issue list -s open -L 500 --json number -R ecmwf/anemoi-$repo | \
        jq -r '.[] | .number' | \
        while read issue; do
            # Transfer the issue
            gh issue transfer "$issue" ecmwf/anemoi -R ecmwf/anemoi-$repo
            
            # Wait a few seconds
            sleep 3
            
            # Add the label to the newly transferred issue in the target repo
            gh issue edit "$issue" -R ecmwf/anemoi --add-label "$repo"
            
            echo "Transferred and labeled issue #$issue from anemoi-$repo"
        done
done
