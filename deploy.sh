#!/bin/bash

echo "🚀 Deploying Kubernetes Shared Development Architecture..."

# Create namespace first
echo "📁 Creating namespace..."
kubectl apply -f namespace.yaml

# Apply RBAC configurations
echo "🔐 Setting up RBAC..."
kubectl apply -f rbac/

# Create storage resources
echo "💾 Setting up storage..."
kubectl apply -f storage/

# Wait for PVC to be bound
echo "⏳ Waiting for PVC to be bound..."
kubectl wait --for=condition=Bound pvc/jekyll-pvc -n development --timeout=60s

# Deploy applications
echo "🚀 Deploying applications..."
kubectl apply -f apps/

# Wait for deployment to be ready
echo "⏳ Waiting for Jekyll deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/jekyll -n development

echo "✅ Deployment complete!"
echo ""
echo "📋 Deployment Summary:"
echo "- Namespace: development"
echo "- User: martin (with developer-role permissions)"
echo "- Application: Jekyll (accessible via NodePort 30080)"
echo "- Storage: 5Gi persistent volume"
echo ""
echo "🔍 Useful commands:"
echo "kubectl get all -n development"
echo "kubectl logs -f deployment/jekyll -n development"
echo "kubectl port-forward service/jekyll-node-service 4000:4000 -n development" 