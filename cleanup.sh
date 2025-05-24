#!/bin/bash

echo "🧹 Cleaning up Kubernetes Shared Development Architecture..."

# Delete applications
echo "🗑️ Removing applications..."
kubectl delete -f apps/ --ignore-not-found=true

# Delete storage resources
echo "💾 Removing storage..."
kubectl delete -f storage/ --ignore-not-found=true

# Delete RBAC configurations
echo "🔐 Removing RBAC..."
kubectl delete -f rbac/ --ignore-not-found=true

# Delete namespace (this will also delete any remaining resources)
echo "📁 Removing namespace..."
kubectl delete -f namespace.yaml --ignore-not-found=true

echo "✅ Cleanup complete!" 