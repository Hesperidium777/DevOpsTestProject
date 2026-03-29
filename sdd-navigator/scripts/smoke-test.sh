#!/bin/bash
set -e

NAMESPACE="sdd-navigator"
API_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/component=api -o jsonpath='{.items[0].metadata.name}')
FRONTEND_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/component=frontend -o jsonpath='{.items[0].metadata.name}')

echo "🔍 Running smoke tests..."

# Test API health
echo "Testing API health endpoint..."
kubectl exec -n $NAMESPACE $API_POD -- curl -s http://localhost:8080/health | grep -q "ok" || exit 1

# Test API readiness
echo "Testing API readiness..."
kubectl exec -n $NAMESPACE $API_POD -- curl -s http://localhost:8080/ready | grep -q "ready" || exit 1

# Test frontend
echo "Testing frontend..."
kubectl exec -n $NAMESPACE $FRONTEND_POD -- curl -s http://localhost:3000 | grep -q "SDD Navigator" || exit 1

# Test database connection
echo "Testing database connection..."
kubectl exec -n $NAMESPACE $API_POD -- sh -c "pg_isready -h sdd-navigator-postgresql" || exit 1

# Test Redis connection
echo "Testing Redis connection..."
kubectl exec -n $NAMESPACE $API_POD -- sh -c "redis-cli -h sdd-navigator-redis-master ping" | grep -q "PONG" || exit 1

echo "✅ All smoke tests passed!"