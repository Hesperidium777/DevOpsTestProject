#!/bin/bash
set -e

echo "🔍 Validating Helm charts..."

# Check Helm installation
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed"
    exit 1
fi

# Lint charts
helm lint helm/sdd-navigator/

# Test template rendering
for env in dev staging prod; do
    echo "Testing template for $env environment..."
    helm template test helm/sdd-navigator/ \
        --values helm/sdd-navigator/values-$env.yaml \
        --debug > /dev/null
done

# Check dependencies
cd helm/sdd-navigator
helm dependency build
helm dependency list

echo "✅ Helm validation passed!"