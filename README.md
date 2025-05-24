# Kubernetes Shared Development Architecture

This repository contains the Kubernetes manifests and scripts to set up a shared development environment as shown in the architecture diagram.

## Architecture Overview

The setup includes:

- **Namespace**: `development` - Isolated environment for development work
- **RBAC**: Role-based access control for user `martin`
- **Storage**: Persistent volume and claim for Jekyll application data
- **Application**: Jekyll static site generator with NodePort service
- **User Access**: Configured access for developer `martin`

## Components

### 1. Namespace (`namespace.yaml`)
- Creates the `development` namespace for resource isolation

### 2. RBAC (`rbac/`)
- **developer-role**: Defines permissions for development activities
- **developer-rolebinding**: Binds the role to user `martin`

### 3. Storage (`storage/`)
- **jekyll-pv**: 5Gi persistent volume using hostPath
- **jekyll-pvc**: Persistent volume claim for the Jekyll application

### 4. Applications (`apps/`)
- **jekyll-deployment**: Jekyll application deployment with persistent storage
- **jekyll-service**: NodePort service exposing Jekyll on port 30080

### 5. User Configuration (`user-config/`)
- **martin-kubeconfig**: Template kubeconfig for user `martin`

## Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or production cluster)
- `kubectl` configured to access your cluster
- Appropriate permissions to create namespaces and RBAC resources

### Deploy the Architecture

1. **Make scripts executable:**
   ```bash
   chmod +x deploy.sh cleanup.sh
   ```

2. **Deploy all components:**
   ```bash
   ./deploy.sh
   ```

3. **Verify deployment:**
   ```bash
   kubectl get all -n development
   ```

### Access the Jekyll Application

1. **Via NodePort (if using minikube):**
   ```bash
   minikube service jekyll-node-service -n development
   ```

2. **Via port-forward:**
   ```bash
   kubectl port-forward service/jekyll-node-service 4000:4000 -n development
   ```
   Then access: http://localhost:4000

3. **Direct NodePort access:**
   - Get your cluster IP and access: `http://<cluster-ip>:30080`

## User Setup (martin)

To set up access for user `martin`:

1. **Generate client certificates** (this depends on your cluster setup)
2. **Update the kubeconfig template** in `user-config/martin-kubeconfig`
3. **Replace placeholders:**
   - `<BASE64_ENCODED_CA_CERT>`: Your cluster's CA certificate
   - `<KUBERNETES_API_SERVER>`: Your cluster's API server address
   - `<BASE64_ENCODED_CLIENT_CERT>`: Martin's client certificate
   - `<BASE64_ENCODED_CLIENT_KEY>`: Martin's client key

## Useful Commands

### Monitoring
```bash
# View all resources in development namespace
kubectl get all -n development

# Check Jekyll logs
kubectl logs -f deployment/jekyll -n development

# Check persistent volume status
kubectl get pv,pvc -n development

# Check RBAC permissions
kubectl auth can-i --list --as=martin -n development
```

### Development Workflow
```bash
# Access Jekyll pod for development
kubectl exec -it deployment/jekyll -n development -- /bin/bash

# Copy files to/from Jekyll pod
kubectl cp local-file.txt development/jekyll-pod:/srv/jekyll/
kubectl cp development/jekyll-pod:/srv/jekyll/file.txt ./local-file.txt
```

## Cleanup

To remove all resources:
```bash
./cleanup.sh
```

## Customization

### Storage
- Modify `storage/jekyll-pv.yaml` to change storage size or type
- For cloud environments, replace `hostPath` with appropriate storage class

### Application
- Update `apps/jekyll-deployment.yaml` to change Jekyll version or configuration
- Modify service type in `apps/jekyll-service.yaml` (NodePort, LoadBalancer, ClusterIP)

### RBAC
- Adjust permissions in `rbac/developer-role.yaml` as needed
- Add more users by creating additional RoleBindings

## Security Considerations

1. **Namespace Isolation**: Resources are isolated within the `development` namespace
2. **RBAC**: User `martin` has limited permissions only within the development namespace
3. **Storage**: Consider using encrypted storage for sensitive data
4. **Network**: NodePort exposes the service - consider using Ingress for production

## Troubleshooting

### Common Issues

1. **PVC not binding:**
   ```bash
   kubectl describe pvc jekyll-pvc -n development
   ```

2. **Pod not starting:**
   ```bash
   kubectl describe pod -l app=jekyll -n development
   kubectl logs -l app=jekyll -n development
   ```

3. **Service not accessible:**
   ```bash
   kubectl get svc jekyll-node-service -n development
   kubectl describe svc jekyll-node-service -n development
   ```

4. **RBAC issues:**
   ```bash
   kubectl auth can-i <verb> <resource> --as=martin -n development
   ```

## Architecture Diagram

The implementation follows this architecture:

```
users
  ↓
┌─────────────────────────────────────────────────────────────────┐
│                    development (namespace)                      │
│                                                                 │
│  martin → kube-config → jekyll-node-service → jekyll            │
│     ↓                           ↓                   ↓           │ 
│  developer-rolebinding     (NodePort)         (pod)             │
│     ↓                                           ↓               │
│  developer-role                            jekyll-pvc           │
│                                                 ↓               │
│                                            jekyll-pv            │
└─────────────────────────────────────────────────────────────────┘
```

This setup provides a secure, isolated development environment with proper access controls and persistent storage for collaborative development work. 