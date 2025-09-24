# Research: Workflow Status and Notifications Dashboard

**Date**: 2025-09-24
**Feature**: Workflow Status and Notifications Dashboard
**Objective**: Investigate existing patterns and technologies for implementing left-column workflow status and notification system

## Research Questions Resolved

### 1. vTeam UI Architecture Analysis

**Decision**: Extend existing NextJS/React patterns
**Rationale**: Current vTeam frontend uses:
- NextJS 15.5.2 with React 19.1.0
- Radix UI components (@radix-ui/react-*)
- Tailwind CSS with class-variance-authority
- Lucide React icons
- Left sidebar navigation pattern already established in project layout

**Alternatives considered**:
- Standalone dashboard application (rejected - adds complexity)
- External widget integration (rejected - not compartmentalized)

### 2. Component Architecture Patterns

**Decision**: Follow existing layout/sidebar patterns from `components/frontend/src/app/projects/[name]/layout.tsx`
**Rationale**:
- Established left sidebar (aside) pattern at 224px width (w-56)
- Navigation items with active states using Button variants
- Icon + label layout with consistent spacing
- Responsive design considerations already handled

**Alternatives considered**:
- Fixed position overlay (rejected - conflicts with existing layout)
- Tab-based interface (rejected - doesn't match "left-column" requirement)

### 3. Real-time Data Integration

**Decision**: Use existing API patterns with polling intervals
**Rationale**: Current implementation uses:
- `getApiUrl()` from `@/lib/config`
- Fetch API with 10-30 second polling intervals
- React hooks (useState, useEffect) for state management
- Project-scoped API endpoints (`/api/projects/:projectName/...`)

**Alternatives considered**:
- WebSocket connections (overkill for this use case)
- Server-sent events (not established in current architecture)

### 4. Workflow Phase Detection

**Decision**: Leverage existing RFE workflow summary endpoint pattern
**Rationale**: Backend already provides:
- `/api/projects/:projectName/rfe-workflows/:id/summary` with phase/status/progress
- File-based phase detection (spec.md, plan.md, tasks.md)
- Session linking via labels (`rfe-workflow`, `project`)
- AgenticSession status tracking

**Alternatives considered**:
- Custom phase tracking system (rejected - duplicates existing logic)
- Manual phase assignment (rejected - not automatic)

### 5. Notification System Design

**Decision**: Icon-based indicators with detail modals
**Rationale**: Consistent with existing patterns:
- Lucide icons available (Bell, Mail, AlertCircle)
- Badge component for count indicators
- Dialog component for detail views
- Card components for structured layouts

**Alternatives considered**:
- Toast notifications (good for temporary alerts, keep for actions)
- Permanent notification list (too much visual noise)

### 6. Metrics Integration

**Decision**: Extend existing placeholder metrics endpoint
**Rationale**: Backend has `/metrics` endpoint stub in `handlers.go:2807-2814`
- Currently returns basic Prometheus format
- Can extend with workflow-specific metrics
- Follows Prometheus naming conventions

**Alternatives considered**:
- Separate metrics service (rejected - adds complexity)
- Frontend-only metrics (rejected - needs backend data)

### 7. State Management

**Decision**: Component-level state with context for shared data
**Rationale**: Matches existing patterns:
- Local state for component-specific data
- Props drilling for simple parent-child communication
- No global state management library in current stack

**Alternatives considered**:
- Redux/Zustand (rejected - overkill for this scope)
- React Query (not in current dependencies)

## Technology Stack Decisions

| Component | Technology | Reasoning |
|-----------|------------|-----------|
| **UI Framework** | React 19.1.0 + NextJS 15.5.2 | Already established in project |
| **Styling** | Tailwind CSS + CVA | Consistent with existing components |
| **Icons** | Lucide React | Already imported and used throughout |
| **Components** | Radix UI primitives | Existing dependency, accessible components |
| **State** | React hooks (useState, useEffect) | Matches current patterns |
| **API Integration** | Fetch API with project-scoped endpoints | Established pattern |
| **Metrics** | Prometheus format extension | Backend stub already exists |

## Implementation Approach

### Phase 1: Core Workflow Status Component
1. Create `WorkflowStatusSidebar` component
2. Integrate with project layout similar to existing navigation sidebar
3. Implement workflow phase detection using existing RFE endpoints
4. Add progress indicators and time/cost display

### Phase 2: Notification System
1. Add notification icon with badge to existing navigation
2. Create notification detail modal
3. Implement "human in the loop" detection logic
4. Add notification state management

### Phase 3: Metrics Extension
1. Extend backend `/metrics` endpoint with workflow-specific metrics
2. Add proper Prometheus labels and naming
3. Include timing, cost, and phase transition metrics

## Risk Mitigation

- **Layout conflicts**: Use existing sidebar patterns and responsive breakpoints
- **Performance**: Implement reasonable polling intervals (30s for status, 10s for active workflows)
- **Type safety**: Create proper TypeScript interfaces for all new data structures
- **Accessibility**: Leverage Radix UI components for built-in accessibility

## Dependencies

**No new external dependencies required** - all functionality can be implemented using existing project dependencies.