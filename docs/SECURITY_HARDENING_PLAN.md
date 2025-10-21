# vTeam Enterprise Security Hardening Plan for OpenShift

*Version 1.0 - Generated 2025-10-21*

## Executive Summary

This document outlines a comprehensive security hardening plan for deploying the vTeam application in enterprise OpenShift environments. The plan addresses critical security vulnerabilities identified during security assessment and provides a phased implementation approach to achieve enterprise-grade security posture.

**Current Security Maturity**: B- (Good foundation, needs hardening)
**Target Security Maturity**: A+ (Enterprise-grade, production-ready)

## Security Assessment Summary

### Key Strengths
- Strong RBAC implementation with SelfSubjectAccessReview
- User-scoped token handling with proper validation
- Token redaction in logs
- Multi-stage container builds
- Per-session workspace isolation

### Critical Gaps Identified
- Missing NetworkPolicies (lateral movement risk)
- Unpinned base images (supply chain risk)
- Query parameter token exposure (log leakage)
- No vulnerability scanning in CI/CD
- Overly permissive backend service account
- Missing pod-level SecurityContext

---

## Phase 1: Critical Security Fixes (Week 1)
**MUST complete before any production deployment**

### 1.1 Pod Security Context Enforcement

#### Implementation Tasks:
1. Add pod-level SecurityContext to all deployments
2. Configure container-level SecurityContext for all containers
3. Bind service accounts to OpenShift restricted-v2 SCC

#### Security Context Configuration:
```yaml
# Apply to all deployments (backend, frontend, operator)
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
        fsGroup: 1001
      containers:
      - name: container-name
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false  # true where possible
          capabilities:
            drop:
              - ALL
          runAsUser: 1001
          runAsGroup: 1001
```

#### Files to Modify:
- `components/manifests/backend-deployment.yaml`
- `components/manifests/frontend-deployment.yaml`
- `components/manifests/operator-deployment.yaml`

### 1.2 Network Segmentation with NetworkPolicies

#### Zero-Trust Network Architecture:
Create NetworkPolicy resources for each component to enforce strict network segmentation.

#### Backend NetworkPolicy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-api-netpol
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:  # Kubernetes API server
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 443
    - to:  # Runner pods
        - podSelector:
            matchLabels:
              app: ambient-code-runner
      ports:
        - protocol: TCP
          port: 8080
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

#### Operator NetworkPolicy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: operator-netpol
spec:
  podSelector:
    matchLabels:
      app: agentic-operator
  policyTypes:
    - Egress
  egress:
    - to:  # Kubernetes API server only
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 443
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

#### Frontend NetworkPolicy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-netpol
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:  # OpenShift Router
        - namespaceSelector:
            matchLabels:
              name: openshift-ingress
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:  # Backend API
        - podSelector:
            matchLabels:
              app: backend-api
      ports:
        - protocol: TCP
          port: 8080
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

#### Runner NetworkPolicy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: runner-netpol
spec:
  podSelector:
    matchLabels:
      app: ambient-code-runner
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: backend-api
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:  # Backend API
        - podSelector:
            matchLabels:
              app: backend-api
      ports:
        - protocol: TCP
          port: 8080
    - to:  # External APIs (GitHub, Anthropic)
        - {}
      ports:
        - protocol: TCP
          port: 443
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

### 1.3 Token Security Improvements

#### Remove Query Parameter Token Support:
Modify `components/backend/handlers/middleware.go`:

```go
// REMOVE this code block (lines 226-230):
// if qp := strings.TrimSpace(c.Query("token")); qp != "" {
//     c.Request.Header.Set("Authorization", "Bearer "+qp)
// }

// OR restrict to WebSocket upgrades only:
if c.IsWebsocket() && qp := strings.TrimSpace(c.Query("token")); qp != "" {
    c.Request.Header.Set("Authorization", "Bearer "+qp)
    // Log security event for audit
    log.Printf("WebSocket token upgrade for user: %s", extractUserFromToken(qp))
}
```

#### Add JWT Signature Validation:
```go
import "github.com/golang-jwt/jwt/v5"

func validateJWTSignature(tokenString string) (*jwt.Claims, error) {
    token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
        // Verify signing method
        if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
        }
        // Return public key for validation
        return loadPublicKey(), nil
    })

    if err != nil {
        return nil, err
    }

    if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
        return &claims, nil
    }

    return nil, fmt.Errorf("invalid token")
}
```

#### Implement Rate Limiting:
```go
import "golang.org/x/time/rate"

var limiterMap = make(map[string]*rate.Limiter)
var mu sync.RWMutex

func rateLimitMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        user := c.GetString("user")
        if user == "" {
            user = c.ClientIP()
        }

        mu.Lock()
        if limiterMap[user] == nil {
            // 100 requests per minute per user
            limiterMap[user] = rate.NewLimiter(rate.Every(time.Minute/100), 10)
        }
        limiter := limiterMap[user]
        mu.Unlock()

        if !limiter.Allow() {
            c.JSON(http.StatusTooManyRequests, gin.H{"error": "rate limit exceeded"})
            c.Abort()
            return
        }

        c.Next()
    }
}
```

### 1.4 Container Image Security

#### Pin Base Images to SHA256 Digests:

##### Backend Dockerfile:
```dockerfile
# FROM alpine:latest
FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
```

##### Frontend Dockerfile:
```dockerfile
# FROM node:20-alpine
FROM node:20-alpine@sha256:2f46fd49c767554c089a5eb219115313b72748d8f62f5eccb58ef52bc36db4ad
```

##### Operator Dockerfile:
```dockerfile
# FROM alpine:latest
FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
```

##### Runner Dockerfile:
```dockerfile
# FROM python:3.11-slim
FROM python:3.11-slim@sha256:4f32a90d7c44553ce6193b8823362c3dc40b765ba80b5e7e68e5b5527d15bca2
```

#### Migrate to Red Hat UBI Images:
```dockerfile
# Backend/Operator - Use UBI9 Minimal
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5-1734497660

# Frontend - Use UBI9 Node.js
FROM registry.access.redhat.com/ubi9/nodejs-20:1-51.1734499081

# Runner - Use UBI9 Python
FROM registry.access.redhat.com/ubi9/python-311:1-77.1734498949
```

#### Add Vulnerability Scanning to CI/CD:
Create `.github/workflows/security-scan.yml`:

```yaml
name: Security Scanning

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        component:
          - frontend
          - backend
          - operator
          - claude-runner
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: |
          docker build -t ${{ matrix.component }}:scan \
            -f components/${{ matrix.component }}/Dockerfile \
            components/${{ matrix.component }}

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ matrix.component }}:scan
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@v3
        with:
          path: ./
          base: ${{ github.event.pull_request.base.sha }}
          head: HEAD
          extra_args: --debug --only-verified
```

### 1.5 RBAC Restrictions

#### Scope Backend ServiceAccount:
Modify `components/manifests/rbac/backend-clusterrole.yaml`:

```yaml
# Change from ClusterRole to Role (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role  # Changed from ClusterRole
metadata:
  name: backend-api-role
  namespace: ambient-code  # Add namespace
rules:
  # Remove cluster-wide permissions
  - apiGroups: [""]
    resources: ["serviceaccounts", "secrets"]
    verbs: ["get", "list", "create", "update", "delete"]
    # Add resourceNames to limit scope
    resourceNames: ["runner-*"]

  # CRD operations remain the same
  - apiGroups: ["vteam.ambient-code"]
    resources: ["agenticsessions", "projectsettings", "rfeworkflows"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  # Job operations for runners
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list", "create", "delete"]
```

---

## Phase 2: High Priority Hardening (Week 2-3)

### 2.1 Secrets Management

#### OpenShift External Secrets Operator Integration:

1. **Install External Secrets Operator:**
```bash
oc apply -f https://operatorhub.io/external-secrets-operator
```

2. **Create SecretStore for HashiCorp Vault:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: ambient-code
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "vteam-backend"
          serviceAccountRef:
            name: "backend-api"
```

3. **Create ExternalSecret for API Keys:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: anthropic-api-key
  namespace: ambient-code
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: anthropic-api-key
    creationPolicy: Owner
  data:
    - secretKey: api-key
      remoteRef:
        key: vteam/anthropic
        property: api_key
```

#### Implement Secret Rotation:

1. **Create rotation CronJob:**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: secret-rotation
  namespace: ambient-code
spec:
  schedule: "0 0 1 * *"  # Monthly
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: secret-rotator
          containers:
          - name: rotator
            image: quay.io/ambient_code/secret-rotator:latest
            command:
              - /bin/sh
              - -c
              - |
                # Rotate service account tokens
                kubectl delete secret -l rotation=enabled
                kubectl create token backend-api --duration=720h

                # Trigger external secret refresh
                kubectl annotate externalsecret --all \
                  force-sync=$(date +%s) --overwrite
```

### 2.2 Internal Service Encryption

#### Deploy OpenShift Service Mesh:

1. **Install Service Mesh Operators:**
```bash
# Install dependencies
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

2. **Create Service Mesh Control Plane:**
```yaml
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: vteam-mesh
  namespace: istio-system
spec:
  version: v2.5
  security:
    dataPlane:
      mtls: true
      automtls: true
    controlPlane:
      mtls: true
  tracing:
    type: Jaeger
    sampling: 10000  # 100%
  proxy:
    networking:
      trafficControl:
        inbound:
          excludedPorts:
            - 15090  # Prometheus metrics
```

3. **Create Service Mesh Member Roll:**
```yaml
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: istio-system
spec:
  members:
    - ambient-code
    - vteam-dev
    - vteam-prod
```

4. **Enable Strict mTLS:**
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: ambient-code
spec:
  mtls:
    mode: STRICT
```

### 2.3 Resource Controls

#### Create ResourceQuotas:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-quota
  namespace: ambient-code
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
    services: "10"
    count/agenticsessions.vteam.ambient-code: "50"
    count/jobs.batch: "20"
```

#### Create LimitRanges:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: ambient-code
spec:
  limits:
  - default:
      cpu: "1"
      memory: 1Gi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    min:
      cpu: 50m
      memory: 64Mi
    max:
      cpu: "4"
      memory: 8Gi
    type: Container
  - min:
      storage: 1Gi
    max:
      storage: 100Gi
    type: PersistentVolumeClaim
```

#### Pod Disruption Budgets:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: backend-pdb
  namespace: ambient-code
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: backend-api
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: operator-pdb
  namespace: ambient-code
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: agentic-operator
```

### 2.4 Supply Chain Security

#### SBOM Generation:
Add to `.github/workflows/components-build-deploy.yml`:

```yaml
- name: Generate SBOM
  uses: anchore/sbom-action@v1
  with:
    image: ${{ env.REGISTRY }}/${{ matrix.component.image }}:${{ github.sha }}
    format: spdx-json
    output-file: ${{ matrix.component.name }}-sbom.json

- name: Upload SBOM to release
  if: github.event_name == 'release'
  uses: actions/upload-release-asset@v1
  with:
    upload_url: ${{ github.event.release.upload_url }}
    asset_path: ${{ matrix.component.name }}-sbom.json
    asset_name: ${{ matrix.component.name }}-sbom.json
    asset_content_type: application/json
```

#### Image Signing with Cosign:
```yaml
- name: Install Cosign
  uses: sigstore/cosign-installer@v3

- name: Sign container image
  env:
    COSIGN_EXPERIMENTAL: 1
  run: |
    cosign sign --yes \
      ${{ env.REGISTRY }}/${{ matrix.component.image }}:${{ github.sha }}

    cosign verify \
      ${{ env.REGISTRY }}/${{ matrix.component.image }}:${{ github.sha }} \
      --certificate-identity-regexp "https://github.com/${{ github.repository }}" \
      --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

---

## Phase 3: Medium Priority Enhancements (Week 4+)

### 3.1 Audit and Compliance

#### Structured Audit Logging:
Implement JSON-formatted audit logs in backend:

```go
type AuditLog struct {
    Timestamp   time.Time              `json:"timestamp"`
    User        string                 `json:"user"`
    UserGroups  []string              `json:"groups,omitempty"`
    SourceIP    string                `json:"source_ip"`
    Method      string                `json:"method"`
    Path        string                `json:"path"`
    Resource    string                `json:"resource,omitempty"`
    Action      string                `json:"action"`
    Namespace   string                `json:"namespace,omitempty"`
    Result      string                `json:"result"`
    StatusCode  int                   `json:"status_code"`
    Duration    time.Duration         `json:"duration_ms"`
    Error       string                `json:"error,omitempty"`
    RequestID   string                `json:"request_id"`
}

func auditMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        requestID := uuid.New().String()
        c.Set("request_id", requestID)

        // Process request
        c.Next()

        // Create audit log entry
        audit := AuditLog{
            Timestamp:  start,
            User:       c.GetString("user"),
            UserGroups: c.GetStringSlice("groups"),
            SourceIP:   c.ClientIP(),
            Method:     c.Request.Method,
            Path:       c.Request.URL.Path,
            Resource:   c.GetString("resource_type"),
            Action:     c.GetString("action"),
            Namespace:  c.Param("projectName"),
            Result:     getResult(c.Writer.Status()),
            StatusCode: c.Writer.Status(),
            Duration:   time.Since(start),
            RequestID:  requestID,
        }

        if len(c.Errors) > 0 {
            audit.Error = c.Errors.String()
        }

        // Write to audit log
        auditLogger.Info("API_AUDIT", zap.Object("audit", audit))
    }
}
```

#### OpenShift Audit Policy:
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log all CRD operations
  - level: RequestResponse
    omitStages:
      - RequestReceived
    resources:
      - group: "vteam.ambient-code"
    namespaces: ["ambient-code", "vteam-*"]

  # Log secret access
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets"]
    namespaces: ["ambient-code", "vteam-*"]
```

### 3.2 Runtime Security

#### Deploy Falco:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-rules
  namespace: ambient-code
data:
  custom_rules.yaml: |
    - rule: Unexpected network connection from runner
      desc: Detect network connections to unexpected destinations
      condition: >
        container.name = "claude-runner" and
        fd.type in (ipv4, ipv6) and
        not fd.sip in (allowed_ips)
      output: >
        Unexpected network connection from runner
        (user=%user.name command=%proc.cmdline connection=%fd.name)
      priority: WARNING

    - rule: Sensitive file access
      desc: Detect access to sensitive files
      condition: >
        open_read and
        fd.name in (/etc/shadow, /etc/passwd, /root/.ssh/*)
      output: >
        Sensitive file accessed
        (user=%user.name file=%fd.name command=%proc.cmdline)
      priority: WARNING
```

#### AppArmor/SELinux Profiles:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: apparmor-profiles
  namespace: ambient-code
data:
  vteam-backend: |
    #include <tunables/global>

    profile vteam-backend flags=(attach_disconnected,mediate_deleted) {
      #include <abstractions/base>

      # Allow network access
      network tcp,
      network udp,

      # Allow reading config
      /etc/vteam/** r,

      # Allow writing to tmp
      /tmp/** rw,

      # Deny everything else
      deny /** w,
    }
```

### 3.3 Operational Security

#### Security Incident Response Runbook:

**1. Detection Phase:**
- Alert triggered from Falco/monitoring
- Identify affected components and scope
- Preserve evidence (logs, pod state)

**2. Containment Phase:**
```bash
# Isolate affected pods
kubectl label pod $POD_NAME quarantine=true
kubectl patch networkpolicy allow-all -p '{"spec":{"podSelector":{"matchLabels":{"quarantine":"false"}}}}'

# Capture pod state
kubectl exec $POD_NAME -- tar czf /tmp/evidence.tar.gz /
kubectl cp $POD_NAME:/tmp/evidence.tar.gz ./evidence-$(date +%s).tar.gz

# Suspend workload
kubectl scale deployment $DEPLOYMENT --replicas=0
```

**3. Eradication Phase:**
```bash
# Rotate all secrets
kubectl delete secret --all -n $NAMESPACE
kubectl rollout restart deployment --all -n $NAMESPACE

# Update images to patched versions
kubectl set image deployment/$DEPLOYMENT *=image:patched

# Clear PVCs if compromised
kubectl delete pvc --all -n $NAMESPACE
```

**4. Recovery Phase:**
```bash
# Restore from clean backup
kubectl apply -f backup/clean-state.yaml

# Gradually restore service
kubectl scale deployment $DEPLOYMENT --replicas=1
# Monitor for 30 minutes
kubectl scale deployment $DEPLOYMENT --replicas=3
```

**5. Lessons Learned:**
- Document timeline and root cause
- Update security controls
- Conduct team retrospective
- Update runbook with findings

---

## Implementation Checklist

### Week 1 Tasks
- [ ] Add SecurityContext to all deployments
- [ ] Create and apply NetworkPolicies
- [ ] Remove query parameter token support
- [ ] Pin all base images to SHA256 digests
- [ ] Add vulnerability scanning to CI/CD
- [ ] Scope backend ServiceAccount permissions

### Week 2-3 Tasks
- [ ] Deploy External Secrets Operator
- [ ] Implement secret rotation automation
- [ ] Install OpenShift Service Mesh
- [ ] Enable mTLS for all services
- [ ] Create ResourceQuotas and LimitRanges
- [ ] Add Pod Disruption Budgets
- [ ] Generate SBOMs for all images
- [ ] Implement image signing with Cosign

### Week 4+ Tasks
- [ ] Implement structured audit logging
- [ ] Archive PVCs to object storage
- [ ] Deploy Falco for runtime security
- [ ] Create AppArmor/SELinux profiles
- [ ] Document incident response procedures
- [ ] Set up security monitoring dashboards
- [ ] Conduct penetration testing
- [ ] Schedule security training for team

---

## Testing and Validation

### Security Testing Plan

1. **RBAC Validation:**
```bash
# Test unauthorized access
kubectl auth can-i create pods --as=system:serviceaccount:ambient-code:backend-api
# Should return: no

# Test authorized access
kubectl auth can-i create jobs --as=system:serviceaccount:ambient-code:backend-api
# Should return: yes
```

2. **NetworkPolicy Testing:**
```bash
# Test blocked connection
kubectl run test-pod --image=busybox --rm -it -- wget backend-api:8080
# Should fail from unauthorized pod

# Test allowed connection
kubectl run test-pod --labels="app=frontend" --image=busybox --rm -it -- wget backend-api:8080
# Should succeed
```

3. **Container Security Testing:**
```bash
# Verify non-root execution
kubectl exec $POD_NAME -- id
# Should show: uid=1001(app) gid=1001(app)

# Test read-only filesystem
kubectl exec $POD_NAME -- touch /test.txt
# Should fail with: Read-only file system
```

4. **Secret Rotation Testing:**
```bash
# Force secret rotation
kubectl annotate secret api-key force-rotation=$(date +%s)

# Verify new secret is generated
kubectl get secret api-key -o jsonpath='{.metadata.creationTimestamp}'
```

### Penetration Testing

1. **OWASP ZAP Scan:**
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t https://vteam.example.com \
  -r penetration_test_report.html
```

2. **Kubernetes Security Benchmark:**
```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs job/kube-bench
```

3. **Container Vulnerability Scan:**
```bash
trivy image --severity HIGH,CRITICAL quay.io/ambient_code/vteam_backend:latest
```

---

## Success Metrics

### Security KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Critical vulnerabilities in production | 0 | Trivy scanning |
| High vulnerabilities in production | <5 | Trivy scanning |
| Time to patch critical vulnerabilities | <24 hours | Incident tracking |
| Unauthorized access attempts blocked | 100% | Audit logs |
| Secret rotation compliance | 100% | Automation metrics |
| mTLS coverage for internal traffic | 100% | Service mesh metrics |
| Pods running as non-root | 100% | Security policy |
| NetworkPolicy coverage | 100% | Policy count |
| Audit log retention | 90 days | Storage metrics |
| Security training completion | 100% | Training records |

### Compliance Checklist

- [ ] SOC 2 Type II requirements met
- [ ] NIST 800-53 controls implemented
- [ ] CIS Kubernetes Benchmark passed
- [ ] OpenShift Security Guide compliance
- [ ] Red Hat security best practices followed
- [ ] Data residency requirements met
- [ ] Audit trail requirements satisfied
- [ ] Incident response plan tested
- [ ] Disaster recovery plan validated
- [ ] Security awareness training completed

---

## Appendix A: Security Resources

### Red Hat Security Documentation
- [OpenShift Security Guide](https://docs.openshift.com/container-platform/4.14/security/index.html)
- [Red Hat Enterprise Linux Security Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/security_hardening/index)
- [UBI Security Compliance](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)

### Security Tools
- [Falco](https://falco.org/) - Runtime security monitoring
- [Trivy](https://trivy.dev/) - Vulnerability scanning
- [Cosign](https://docs.sigstore.dev/cosign/overview/) - Container signing
- [External Secrets Operator](https://external-secrets.io/) - Secret management
- [OWASP ZAP](https://www.zaproxy.org/) - Web application security testing

### Security Standards
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Cloud Native Security Whitepaper](https://github.com/cncf/tag-security/blob/main/security-whitepaper/v2/cloud-native-security-whitepaper.md)

---

## Appendix B: Emergency Contacts

### Security Incident Response Team
- **Primary Contact**: Security Team Lead
- **Escalation**: Platform Engineering Manager
- **24/7 Hotline**: [To be configured]
- **Email**: security@vteam.example.com

### Vendor Support
- **Red Hat Support**: [Access Portal](https://access.redhat.com)
- **OpenShift Support**: Premium support contract
- **Anthropic Security**: security@anthropic.com

---

*This document is version controlled and should be reviewed quarterly. Last update: 2025-10-21*