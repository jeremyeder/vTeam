# Data Model: Workflow Status and Notifications Dashboard

**Date**: 2025-09-24
**Feature**: Workflow Status and Notifications Dashboard

## Entity Definitions

Based on the feature specification and existing vTeam architecture, the following entities are required:

### 1. WorkflowStatus

Represents the current state and progress of a workflow through the vTeam orchestration phases.

**Fields**:
- `id: string` - Unique workflow identifier
- `projectName: string` - Associated project namespace
- `currentPhase: WorkflowPhase` - Current phase in workflow
- `status: WorkflowStatusType` - Overall status indicator
- `progress: number` - Completion percentage (0-100)
- `startTime?: string` - ISO timestamp when workflow started
- `lastUpdated: string` - ISO timestamp of last status update
- `estimatedCompletion?: string` - ISO timestamp estimate
- `stepMetrics: WorkflowStepMetric[]` - Per-step timing and cost data

**Validation Rules**:
- `id` must be non-empty string matching K8s resource name pattern
- `projectName` must be valid K8s namespace name
- `progress` must be between 0 and 100
- `lastUpdated` must be valid ISO timestamp

**State Transitions**:
```
pre → specify → plan → tasks → implement → completed
  ↓      ↓       ↓      ↓        ↓
 failed  failed  failed failed  failed
```

### 2. WorkflowStepMetric

Represents metrics and attribution for individual workflow steps.

**Fields**:
- `stepName: string` - Step identifier (clarify, specify, plan, tasks, implement)
- `status: StepStatus` - Step completion status
- `timeSpent: number` - Duration in milliseconds
- `cost: number` - Cost in USD
- `attributedTo: string` - User or system that processed step
- `toolsUsed: string[]` - LLM models or tools utilized
- `startTime?: string` - ISO timestamp when step started
- `endTime?: string` - ISO timestamp when step completed
- `metadata: Record<string, any>` - Additional step-specific data

**Validation Rules**:
- `stepName` must be one of valid workflow phases
- `timeSpent` and `cost` must be non-negative numbers
- `toolsUsed` must be array of non-empty strings

### 3. WorkflowNotification

Represents notifications for human-in-the-loop workflow actions.

**Fields**:
- `id: string` - Unique notification identifier
- `workflowId: string` - Associated workflow ID
- `projectName: string` - Project namespace
- `type: NotificationType` - Category of notification
- `priority: NotificationPriority` - Urgency level
- `title: string` - Short notification title
- `message: string` - Detailed notification content
- `actionRequired: boolean` - Whether user action is needed
- `actionUrl?: string` - URL for user to take action
- `createdAt: string` - ISO timestamp when notification created
- `readAt?: string` - ISO timestamp when user read notification
- `assignedTo?: string` - Specific user notification is for
- `metadata: Record<string, any>` - Additional notification data

**Validation Rules**:
- All timestamp fields must be valid ISO strings
- `title` must be 1-100 characters
- `message` must be non-empty string
- `actionUrl` must be valid URL if provided

### 4. UserWorkflowContext

Represents user-specific workflow dashboard context and preferences.

**Fields**:
- `userId: string` - User identifier
- `activeWorkflows: string[]` - List of workflow IDs user is monitoring
- `notificationPreferences: NotificationPreferences` - User's notification settings
- `dashboardLayout: DashboardLayout` - UI layout preferences
- `lastActive: string` - ISO timestamp of last dashboard activity

**Validation Rules**:
- `userId` must be non-empty string
- `activeWorkflows` must be array of valid workflow IDs
- `lastActive` must be valid ISO timestamp

## Enums

### WorkflowPhase
```typescript
enum WorkflowPhase {
  PRE = 'pre',
  CLARIFY = 'clarify',
  SPECIFY = 'specify',
  PLAN = 'plan',
  TASKS = 'tasks',
  IMPLEMENT = 'implement',
  COMPLETED = 'completed'
}
```

### WorkflowStatusType
```typescript
enum WorkflowStatusType {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  RUNNING = 'running',
  COMPLETED = 'completed',
  ATTENTION = 'attention',
  FAILED = 'failed'
}
```

### StepStatus
```typescript
enum StepStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed',
  SKIPPED = 'skipped'
}
```

### NotificationType
```typescript
enum NotificationType {
  WORKFLOW_STARTED = 'workflow_started',
  STEP_COMPLETED = 'step_completed',
  ACTION_REQUIRED = 'action_required',
  WORKFLOW_FAILED = 'workflow_failed',
  WORKFLOW_COMPLETED = 'workflow_completed',
  HANDOFF_READY = 'handoff_ready'
}
```

### NotificationPriority
```typescript
enum NotificationPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}
```

## Supporting Types

### NotificationPreferences
```typescript
interface NotificationPreferences {
  enabledTypes: NotificationType[];
  emailNotifications: boolean;
  browserNotifications: boolean;
  quietHours: {
    enabled: boolean;
    startTime: string; // HH:mm format
    endTime: string;   // HH:mm format
  };
}
```

### DashboardLayout
```typescript
interface DashboardLayout {
  sidebarWidth: number;
  showMetrics: boolean;
  compactMode: boolean;
  sortBy: 'lastUpdated' | 'priority' | 'progress';
  groupBy: 'project' | 'phase' | 'none';
}
```

## Data Relationships

1. **WorkflowStatus** ↔ **WorkflowStepMetric**: One-to-many relationship via `stepMetrics` array
2. **WorkflowStatus** ↔ **WorkflowNotification**: One-to-many relationship via `workflowId` foreign key
3. **UserWorkflowContext** ↔ **WorkflowStatus**: Many-to-many relationship via `activeWorkflows` array
4. **WorkflowNotification** ↔ **UserWorkflowContext**: Many-to-many relationship via `assignedTo` and `userId`

## Data Sources

Based on existing vTeam backend architecture:

1. **Workflow Status**: Derived from RFEWorkflow CRDs and associated AgenticSession resources
2. **Step Metrics**: Extracted from AgenticSession status fields (`cost`, `duration_ms`, `usage`, etc.)
3. **Notifications**: Generated by workflow state transitions and stored in backend
4. **User Context**: Stored per-user in backend state or browser localStorage

## Persistence Strategy

- **Backend State**: WorkflowStatus and WorkflowNotification stored via existing API patterns
- **User Preferences**: Stored in browser localStorage with backend sync
- **Real-time Updates**: Polling-based updates every 10-30 seconds
- **Metrics Export**: Prometheus metrics derived from workflow and step data