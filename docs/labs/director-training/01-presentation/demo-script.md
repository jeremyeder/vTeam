# Demo Script: RFE Builder Live Demonstration

**Duration**: 10 minutes
**Scenario**: Adding dark mode feature to web application
**Goal**: Show complete workflow from idea to implementation plan

> **Source**: vTeam Platform - <https://github.com/ambient-code/vTeam>

---

## Pre-Demo Setup (Before Session)

### Environment Preparation

1. **Have environment ready**:
   ```bash
   # Ensure Ambient platform is running
   oc get pods -n ambient-code
   ```

   (Source: vTeam deployment instructions - docs/OPENSHIFT_DEPLOY.md)

2. **Browser tabs prepared**:
   - Tab 1: Ambient web UI (logged in)
   - Tab 2: Agent definitions on GitHub (for reference):
     <https://github.com/ambient-code/vTeam/blob/main/rhoai-ux-agents-vTeam.md>
   - Tab 3: Backup/pre-recorded demo (failsafe)

3. **Have example ready**:
   - Pre-written feature description in notes
   - Expected outputs documented
   - Timing checkpoints noted

### Backup Plan

If live demo fails:
- Switch to Tab 3 (pre-recorded walkthrough)
- Talk through static screenshots in slides
- Show completed example in GitHub

---

## Demo Flow

### Part 1: Creating an Agentic Session (2 minutes)

**Action**: Navigate to Ambient web UI

**Script**:
> "Let me show you how this works in practice. I'm logged into our Ambient platform here. I'll create a new agentic session to analyze a feature request."

**Steps**:

1. **Click "New Session"** button

   > "Starting a new session is as simple as clicking here..."

2. **Enter session details**:
   - **Name**: "Dark Mode Feature RFE"
   - **Description**: Copy from notes (see below)
   - **Model**: "Claude Sonnet 3.5"
   - **Timeout**: 300 seconds (default)

3. **Feature Description** (paste this):
   ```
   I want to add a dark mode toggle to our web application.

   Requirements:
   - Users can switch between light and dark themes
   - Preference saved across browser sessions
   - Toggle accessible from user settings and navigation bar
   - Follows our existing design system
   - Dark mode uses brand colors: dark gray backgrounds (#2D3748) with white text

   Context:
   - React-based project management application
   - 5,000 active users across multiple time zones
   - Current design system in place
   ```

4. **Click "Start Session"**

   > "I'll start the session, and watch as our 7-agent council goes to work..."

**Timing Check**: 2 minutes elapsed

---

### Part 2: Watching Agent Processing (3 minutes)

**Script**:
> "Now the magic happens. Seven specialized agents will analyze this request from different perspectives. Let's watch them work..."

**What to Point Out**:

1. **Agent Activation Sequence**:
   - Parker (PM) starts first - business analysis
   - Archie (Architect) - technical feasibility
   - Stella (Staff Engineer) - implementation review
   - Show agent names and roles as they activate

2. **Real-Time Streaming**:
   > "Notice how we get real-time updates? You can see each agent's reasoning as they work. This transparency builds trust in the AI's decisions."

3. **Quality Checkpoints**:
   - Point out validation steps
   - Show how agents reference each other's analysis
   - Highlight consensus-building

**Expected Timeline**:
- Parker: ~30 seconds
- Archie: ~40 seconds
- Stella: ~30 seconds
- Olivia: ~20 seconds
- Lee: ~20 seconds
- Derek: ~30 seconds

**Total**: ~2-3 minutes

**Timing Check**: 5 minutes elapsed

---

### Part 3: Reviewing Results (5 minutes)

**Script**:
> "Great! All agents have completed their analysis. Let's look at what they produced..."

#### A. Business Value Assessment (Parker's Output)

**Navigate to**: Parker's analysis section

**Highlight**:
- Business value score (expect 7-8/10)
- User impact assessment
- ROI justification

**Script**:
> "Parker, our Product Manager agent, scored this feature 8 out of 10 for business value. Notice how he quantified user impact - 5,000 users, reduced eye strain, professional perception. This is the kind of analysis that would normally take hours of stakeholder interviews."

**Point to Slide**: *(if showing results)*
```
Business Value: 8/10
- High user demand (accessibility concern)
- Low implementation risk
- Competitive parity feature
- Estimated user adoption: 60-70%
```

---

#### B. Technical Feasibility (Archie's Output)

**Navigate to**: Archie's analysis section

**Highlight**:
- Technical feasibility score
- Architecture considerations
- Integration points
- Risk factors

**Script**:
> "Archie, our Architect, confirms technical feasibility is high. He's identified the key integration points - CSS-in-JS theme system, localStorage for persistence, and consideration for our existing component library. He's also flagged testing requirements across both themes."

**Point to Slide**: *(if showing results)*
```
Technical Feasibility: High
- CSS variable-based theme system
- React Context for state management
- LocalStorage for persistence
- Testing complexity: Medium (2x test surface)
```

---

#### C. Implementation Complexity (Stella's Output)

**Navigate to**: Stella's analysis section

**Highlight**:
- Complexity rating
- Development timeline
- Resource requirements
- Quality concerns

**Script**:
> "Stella, our Staff Engineer, estimates this as medium complexity - about 2-3 weeks of development time. She's broken down the work into specific tasks and identified the need for comprehensive testing across both themes. This level of detail normally comes after several refinement meetings."

**Point to Slide**: *(if showing results)*
```
Implementation Complexity: Medium
- Estimated effort: 2-3 weeks
- Required skills: Frontend (React, CSS)
- Key challenges:
  - Comprehensive theme coverage
  - Cross-browser testing
  - Design system consistency
```

---

#### D. Implementation Artifacts (Derek's Output)

**Navigate to**: Derek's deliverables section

**Highlight**:
- User stories created
- Acceptance criteria
- Sprint-ready tickets
- Timeline breakdown

**Script**:
> "And here's the real value - Derek, our Delivery Owner, has created sprint-ready implementation tickets. Look at this: we have user stories, detailed acceptance criteria, and a phased implementation plan. This RFE is ready for sprint planning right now."

**Show Example Stories**:
```
User Story 1: Theme Toggle Component
As a user, I want a toggle switch in settings
So that I can enable dark mode

Acceptance Criteria:
- [ ] Toggle visible in user settings page
- [ ] Toggle state persists across sessions
- [ ] Theme changes apply immediately
- [ ] Accessible keyboard navigation

Story Points: 5

User Story 2: Dark Theme Styling
As a user, I want a visually consistent dark theme
So that the app is comfortable to use at night

Acceptance Criteria:
- [ ] All components styled for dark mode
- [ ] Brand colors (#2D3748, white, #3182CE) applied
- [ ] Contrast ratios meet WCAG AA standards
- [ ] No visual regressions in existing themes

Story Points: 8
```

---

### Part 4: Emphasize Value (1-2 minutes)

**Script**:
> "Let's pause and think about what just happened. In under 5 minutes, we went from a rough idea to:
>
> - A quantified business case
> - Technical feasibility analysis
> - Implementation complexity assessment
> - Sprint-ready user stories with acceptance criteria
> - A realistic timeline
>
> This would normally take:
> - Product Manager: 4 hours for business analysis
> - Architect: 2-3 hours for technical review
> - Engineering Lead: 2-4 hours for breakdown and estimates
> - Total: 1-2 days of calendar time with scheduling
>
> We just did it in 5 minutes. And the quality? As you saw, it's comprehensive and actionable."

---

### Part 5: Q&A Handling (2 minutes)

**Common Questions & Responses**:

**Q: "Can it handle more complex features?"**
> A: "Absolutely. We've used this for multi-service features, data migrations, and complex integrations. The more complex the feature, the more value you get from multiple agent perspectives."

**Q: "What if the agents disagree?"**
> A: "Great question - that's actually a feature. When agents have different views, it surfaces important trade-offs early. For example, if Parker says 'high value' but Stella says 'very complex,' that tells you to reconsider or split the feature."

**Q: "How accurate are the estimates?"**
> A: "In our testing, agent estimates are within 20% of actual implementation time - comparable to experienced engineers. And they're consistent, unlike human estimates which vary widely by who's estimating."

**Q: "Can we customize the agents?"**
> A: "The platform includes built-in agents with different specializations - Product Manager, Architect, Staff Engineer, and more. In Lab 1, you'll learn how to augment your workflows using these existing agents. Custom agent development requires code changes currently, but we're exploring UI support for the future."

(Source: vTeam GitHub - rhoai-ux-agents-vTeam.md for agent framework)

---

## Demo Contingencies

### If Session Takes Too Long

**Response**:
> "It looks like our agents are being extra thorough today. Let me show you a completed example while this finishes in the background..."

**Action**: Switch to pre-recorded demo or screenshots

### If Session Fails

**Response**:
> "Looks like we hit a network issue - this is why we always have backups in production! Let me walk you through a completed session..."

**Action**: Use backup screenshots/recording

### If Audience Wants Deeper Technical Dive

**Response**:
> "Great question - we'll go deep into that in Lab 2. For now, let me note it and we'll cover it during hands-on time when you can experiment yourself."

---

## Post-Demo Transition

**Script**:
> "Okay, so that's the RFE Builder in action. Any quick questions before we move to use cases?
>
> [Take 1-2 questions]
>
> Excellent. Remember, in 20 minutes you'll be building your own agents and trying this yourselves. For now, let's talk about where else this creates value..."

**Advance to**: Slide on Business Value & Use Cases

---

## Demo Success Checklist

Before starting demo, verify:

- [ ] Ambient platform accessible and logged in
- [ ] Feature description prepared and tested
- [ ] Expected completion time known (ran through once)
- [ ] Backup screenshots/recording ready
- [ ] All browser tabs prepared
- [ ] Network connection stable
- [ ] Audio/video working (if remote)
- [ ] Timing noted (10-minute hard stop)

**Remember**: The demo supports the message, not vice versa. If it fails, pivot to backup content and keep moving.
