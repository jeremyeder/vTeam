workspace "vTeam Platform" "Kubernetes-native AI automation platform for intelligent agentic sessions" {

    model {
        # People
        user = person "Platform User" "Engineering team member who creates and manages AI-powered agentic sessions for automation tasks"
        admin = person "Platform Administrator" "Red Hat SRE/Platform team member who manages infrastructure and multi-tenant configuration"

        # External Systems
        anthropic = softwareSystem "Anthropic API" "Claude AI language model service providing intelligent code generation and analysis capabilities" {
            tags "External System"
        }

        k8s = softwareSystem "Kubernetes/OpenShift Cluster" "Container orchestration platform providing compute, storage, and networking infrastructure" {
            tags "External System"
        }

        github = softwareSystem "GitHub" "Source code repository and CI/CD platform for vTeam development" {
            tags "External System"
        }

        # vTeam Platform
        vteam = softwareSystem "vTeam Platform" "Ambient Agentic Runner - Kubernetes-native AI automation platform" {

            # Frontend Container
            frontend = container "Frontend Web Application" "User interface for creating and monitoring AI sessions" "NextJS 14, TypeScript, Shadcn UI" {
                sessionUI = component "Session Management UI" "Create, monitor, and manage agentic sessions" "React Components"
                projectUI = component "Project Management UI" "Multi-tenant project organization" "React Components"
                settingsUI = component "Settings & Secrets UI" "Configure runner secrets and API keys" "React Components"
                authHandler = component "Authentication Handler" "OpenShift OAuth integration" "NextAuth.js"

                tags "Web Browser"
            }

            # Backend Container
            backend = container "Backend API Service" "REST API for managing Kubernetes Custom Resources" "Go, Gin Framework" {
                projectsAPI = component "Projects API" "Multi-tenant project CRUD operations" "Go HTTP Handlers"
                sessionsAPI = component "Sessions API" "Agentic session lifecycle management" "Go HTTP Handlers"
                secretsAPI = component "Secrets API" "Secure storage of runner API keys" "Go HTTP Handlers"
                rbacMiddleware = component "RBAC Middleware" "Authorization and multi-tenancy enforcement" "Go Middleware"
                k8sClient = component "Kubernetes Client" "Custom Resource management" "client-go"

                tags "API"
            }

            # Operator Container
            operator = container "Agentic Operator" "Kubernetes operator watching Custom Resources and creating Jobs" "Go, Kubebuilder, controller-runtime" {
                projectController = component "Project Controller" "Reconciles Project CRs, manages namespaces" "controller-runtime"
                sessionController = component "Session Controller" "Reconciles AgenticSession CRs, creates Jobs" "controller-runtime"
                resourceManager = component "Resource Manager" "Manages quotas, network policies, RBAC" "controller-runtime"
                jobOrchestrator = component "Job Orchestrator" "Creates and monitors Kubernetes Jobs for AI runners" "controller-runtime"

                tags "Kubernetes Operator"
            }

            # Runner Container
            runner = container "Claude Code Runner" "Execution pod running Claude Code CLI with multi-agent capabilities" "Python, Claude Code CLI" {
                agentLoader = component "Agent Loader" "Loads and orchestrates 17 specialized AI agents" "Python"
                mcpIntegration = component "MCP Integration" "Model Context Protocol for browser automation" "Python, MCP SDK"
                sessionExecutor = component "Session Executor" "Executes AI tasks and stores results" "Python"
                claudeAPI = component "Claude API Client" "Communicates with Anthropic API" "Python, anthropic SDK"

                tags "AI Runner"
            }

            # Data Storage (Kubernetes)
            database = container "Custom Resources (etcd)" "Kubernetes API storage for Custom Resource Definitions" "Kubernetes etcd" {
                tags "Database"
            }

            secretsStore = container "Kubernetes Secrets" "Encrypted secret storage for API keys and credentials" "Kubernetes Secrets" {
                tags "Database"
            }
        }

        # Relationships - User Interactions
        user -> frontend "Creates AI sessions, monitors progress via" "HTTPS"
        admin -> k8s "Deploys and manages platform via" "oc/kubectl CLI"

        # Relationships - Frontend to Backend
        frontend -> backend "Makes API calls to" "HTTPS, REST"
        sessionUI -> sessionsAPI "Creates/reads sessions"
        projectUI -> projectsAPI "Manages projects"
        settingsUI -> secretsAPI "Configures API keys"
        authHandler -> rbacMiddleware "Authenticates requests"

        # Relationships - Backend to Kubernetes
        backend -> database "Reads/writes Custom Resources via" "Kubernetes API"
        backend -> secretsStore "Stores encrypted secrets via" "Kubernetes API"
        k8sClient -> database "Manages CRs"
        k8sClient -> secretsStore "Manages secrets"

        # Relationships - Operator Workflows
        operator -> database "Watches Custom Resources via" "Kubernetes API"
        projectController -> database "Reconciles Project CRs"
        sessionController -> database "Reconciles AgenticSession CRs"
        sessionController -> jobOrchestrator "Triggers Job creation"
        resourceManager -> k8s "Creates namespaces, quotas, RBAC"
        jobOrchestrator -> k8s "Creates Kubernetes Jobs"

        # Relationships - Runner Execution
        k8s -> runner "Schedules pods for"
        runner -> database "Updates session status in" "Kubernetes API"
        sessionExecutor -> claudeAPI "Executes AI tasks via"
        claudeAPI -> anthropic "Calls Claude AI API via" "HTTPS"
        agentLoader -> sessionExecutor "Provides agent context to"
        mcpIntegration -> sessionExecutor "Provides browser automation to"

        # Relationships - External Integrations
        runner -> secretsStore "Reads API keys from" "Kubernetes API"
        frontend -> github "Deploys via" "GitHub Actions"
        backend -> github "Deploys via" "GitHub Actions"
        operator -> github "Deploys via" "GitHub Actions"

        # Deployment Environment
        deploymentEnvironment "Production" {
            deploymentNode "OpenShift Cluster" "Red Hat OpenShift 4.x" "Kubernetes" {
                tags "OpenShift"

                deploymentNode "ambient-code Namespace" "Multi-tenant project namespace" {

                    deploymentNode "Frontend Pod" "NextJS application pod" "Kubernetes Pod" {
                        containerInstance frontend
                    }

                    deploymentNode "Backend Pod" "Go API service pod" "Kubernetes Pod" {
                        containerInstance backend
                    }

                    deploymentNode "Operator Pod" "Kubernetes operator pod" "Kubernetes Pod" {
                        containerInstance operator
                    }

                    deploymentNode "Runner Job Pod" "AI execution pod (ephemeral)" "Kubernetes Job Pod" {
                        containerInstance runner
                    }
                }

                deploymentNode "kube-system" "Kubernetes system namespace" {
                    deploymentNode "etcd Cluster" "Distributed key-value store" "etcd" {
                        containerInstance database
                    }
                }
            }

            deploymentNode "External Services" {
                softwareSystemInstance anthropic
            }
        }
    }

    views {
        # System Context Diagram
        systemContext vteam "SystemContext" {
            include *
            autoLayout
            description "System context diagram for vTeam platform showing users, external systems, and high-level interactions"
        }

        # Container Diagram
        container vteam "Containers" {
            include *
            autoLayout
            description "Container diagram showing the major technical building blocks of vTeam platform"
        }

        # Component Diagrams
        component frontend "FrontendComponents" {
            include *
            autoLayout
            description "Component diagram showing internal structure of the Frontend container"
        }

        component backend "BackendComponents" {
            include *
            autoLayout
            description "Component diagram showing internal structure of the Backend API container"
        }

        component operator "OperatorComponents" {
            include *
            autoLayout
            description "Component diagram showing internal structure of the Kubernetes Operator"
        }

        component runner "RunnerComponents" {
            include *
            autoLayout
            description "Component diagram showing internal structure of the Claude Code Runner"
        }

        # Deployment Diagram
        deployment vteam "Production" "Deployment" {
            include *
            autoLayout
            description "Deployment diagram showing how vTeam containers are deployed to OpenShift"
        }

        # Dynamic Diagram - Session Creation Flow
        dynamic vteam "SessionCreationFlow" "Session Creation and Execution Flow" {
            user -> frontend "1. Creates new AI session"
            frontend -> backend "2. POST /api/sessions"
            backend -> database "3. Creates AgenticSession CR"
            operator -> database "4. Watches CR creation"
            operator -> k8s "5. Creates Kubernetes Job"
            k8s -> runner "6. Schedules runner pod"
            runner -> anthropic "7. Executes AI tasks via Claude API"
            runner -> database "8. Updates session status"
            frontend -> backend "9. Polls session status"
            backend -> database "10. Reads updated CR"
            backend -> frontend "11. Returns results"
            frontend -> user "12. Displays session output"
            autoLayout
        }

        # Styles
        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Database" {
                shape Cylinder
            }
            element "API" {
                shape Hexagon
            }
            element "Kubernetes Operator" {
                shape Component
            }
            element "AI Runner" {
                shape Robot
            }
            element "OpenShift" {
                background #EE0000
                color #ffffff
            }
        }

        # Themes
        themes default https://static.structurizr.com/themes/kubernetes-v0.3/theme.json
    }

    configuration {
        scope softwaresystem
    }

}
