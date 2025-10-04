#!/bin/bash

# Check for --skip-error flag
skip_error=false
if [[ "$*" == *"--skip-error"* ]]; then
    skip_error=true
fi

echo "super_lint is running..."
cmd=$( dart run custom_lint )
echo -e "$cmd"

if grep -q " • WARNING" <<< "$cmd"; then
    echo "super_lint: Warnings found."
    if [ "$skip_error" = true ]; then
        echo "super_lint: Skip error mode - continuing..."
    else
        exit 1
    fi
fi

if grep -q " • ERROR" <<< "$cmd"; then
    echo "super_lint: Errors found."
    if [ "$skip_error" = true ]; then
        echo "super_lint: Skip error mode - continuing..."
    else
        exit 1
    fi
fi

echo "*** super_lint: Error and Warnings checks passed successfully. ***"
