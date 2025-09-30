# vTeam C4 Model Implementation Roadmap

**Project**: Red Hat AI-Assisted Development Initiative - C4 Architecture Integration
**Repository**: vTeam (Ambient Agentic Runner)
**Owner**: Jeremy Eder, Distinguished Engineer
**Created**: 2025-09-30
**Status**: Research Complete → Implementation Planning

---

## Executive Summary

This roadmap outlines the phased implementation of C4 model architecture for Red Hat's AI-assisted development initiative, using vTeam as the prototype. The goal is to enable **any LLM to generate enterprise-quality code deterministically** by providing structured architecture diagrams alongside implementation prompts.

### Current State (2025-09-30)

✅ **Research Complete**:
- Comprehensive C4 vs prompting analysis (17,000 words)
- vTeam C4 baseline architecture (workspace.dsl)
- 8 architecture diagrams generated
- Integration strategy documented

✅ **Deliverables**:
- `docs/research/c4-vs-prompting-analysis.md` - Full analysis
- `architecture/workspace.dsl` - C4 model definition
- `architecture/README.md` - Usage documentation
- `architecture/diagrams/` - Generated diagrams

### Strategic Recommendation

**Hybrid Approach**: C4 for architecture layer + extensive prompting for implementation details + automated validation.

---

## Phase 0: Foundation (Complete) ✅

**Timeline**: Week of 2025-09-30
**Status**: COMPLETE

### Objectives
- [x] Research C4 model vs extensive prompting across full SDLC
- [x] Analyze open source community adoption barriers
- [x] Create vTeam C4 baseline architecture
- [x] Document greenfield and brownfield integration strategies
- [x] Establish tooling recommendations

### Deliverables
- [x] Comprehensive analysis document (17k+ words)
- [x] C4 workspace.dsl for vTeam (4 containers, 17 components)
- [x] 8 architecture diagrams (Context, Containers, Components×4, Deployment, Dynamic)
- [x] Architecture README with LLM integration patterns
- [x] Updated CLAUDE.md with architecture-first guidance

### Validation Criteria
- [x] Diagrams viewable via Structurizr Lite (Jeremy confirmed)
- [x] Architecture accurately represents vTeam platform
- [x] Documentation provides clear guidance for LLM usage

---

## Phase 1: Baseline Adoption (Month 1)

**Timeline**: 2025-10-01 to 2025-10-31 (4 weeks)
**Goal**: Prove C4 value within vTeam team, establish baseline metrics

### Week 1: Tooling & CI/CD Integration

**Objectives**:
- Automate diagram generation in CI/CD
- Establish architecture validation workflow
- Train team on C4 fundamentals

**Tasks**:
- [ ] Create GitHub Actions workflow for diagram generation
  ```yaml
  # .github/workflows/c4-diagrams.yaml
  name: Generate C4 Diagrams
  on: [push, pull_request]
  jobs:
    diagrams:
      - uses: structurizr/cli-action@v1
      - run: structurizr-cli export -w architecture/workspace.dsl -f plantuml -o architecture/diagrams/
      - run: plantuml architecture/diagrams/*.puml
      - uses: actions/upload-artifact@v3
        with:
          name: architecture-diagrams
          path: architecture/diagrams/*.png
  ```
- [ ] Add pre-commit hook: Validate workspace.dsl syntax
- [ ] Schedule 2-hour team workshop: "C4 Model Fundamentals"
- [ ] Create team documentation: "How to read vTeam architecture diagrams"

**Deliverables**:
- GitHub Actions workflow file
- Pre-commit validation script
- Team workshop slides and recording
- Quick reference guide

**Success Criteria**:
- Diagrams auto-generate on every commit
- All team members complete C4 training
- Zero build failures due to invalid DSL

### Week 2: First C4-Guided Feature Development

**Objectives**:
- Develop one new feature using C4-first workflow
- Measure developer experience and productivity
- Identify workflow gaps

**Feature Candidate**: Add "Session Templates" to vTeam
- Allows users to save/reuse session configurations
- Touches multiple components (Frontend UI, Backend API, CR schema)
- Good test case for architecture-driven development

**Tasks**:
- [ ] Update workspace.dsl: Add SessionTemplate component to Backend
- [ ] Generate updated diagrams
- [ ] LLM prompt: "Generate Go code for SessionTemplate component based on C4 architecture"
- [ ] Implement feature following component boundaries
- [ ] Track time: architecture update vs LLM generation vs manual refinement
- [ ] Developer retrospective: What worked? What didn't?

**Deliverables**:
- Updated workspace.dsl (SessionTemplate component)
- LLM-generated code scaffolding
- Implementation PR with architecture alignment notes
- Developer experience survey results

**Success Criteria**:
- Feature implementation respects C4 component boundaries
- LLM generates 70%+ accurate code scaffolding
- Developer reports positive experience with architecture-first workflow

### Week 3: Baseline Metrics Collection

**Objectives**:
- Establish quantitative baselines for success metrics
- Measure current state before/after C4 adoption
- Identify architecture-code drift

**Metrics to Collect**:

1. **Architectural Consistency**
   - Measure: Manual code review - does code match C4 boundaries?
   - Baseline: Review 10 recent PRs, count violations
   - Target: <5 violations per PR

2. **LLM Code Generation Accuracy**
   - Measure: Generate code 3 times from same architecture, compare structural similarity
   - Baseline: Generate Backend API endpoint with/without C4 context
   - Target: 80% structural consistency with C4, 50% without

3. **Knowledge Transfer Speed**
   - Measure: Time for new team member to understand system
   - Baseline: New hire onboarding survey (current narrative docs)
   - Target: 50% reduction with C4 diagrams

4. **Change Impact Prediction**
   - Measure: Accuracy of "affected components" prediction before implementation
   - Baseline: Review 5 completed features, compare planned vs actual impact
   - Target: 90% accuracy with C4 diagrams

**Tasks**:
- [ ] Create metrics dashboard (Google Sheets or Grafana)
- [ ] Run baseline measurements (before C4 widespread adoption)
- [ ] Document measurement procedures for consistency
- [ ] Schedule weekly metrics review meetings

**Deliverables**:
- Metrics dashboard with baseline data
- Measurement procedures documentation
- Weekly metrics review notes

**Success Criteria**:
- All 4 metrics have documented baselines
- Team agrees on measurement procedures
- Dashboard accessible to all team members

### Week 4: Architecture Validation Automation

**Objectives**:
- Implement automated architecture-code validation
- Detect architecture drift in CI/CD
- Create feedback loop for architecture evolution

**Tasks**:
- [ ] Research ArchUnit for Go (go-archunit or alternatives)
- [ ] Write first architecture test: "Backend components cannot directly call Kubernetes API"
  ```go
  // tests/architecture/component_boundaries_test.go
  func TestBackendComponentsBoundaries(t *testing.T) {
      // Ensure Sessions API only calls through Kubernetes Client component
      // Not directly to client-go
  }
  ```
- [ ] Add ArchUnit tests to CI/CD
- [ ] Create "Architecture Drift Report" in PR checks
- [ ] Document how to write new architecture tests

**Deliverables**:
- ArchUnit test suite (minimum 3 tests)
- CI/CD integration for architecture validation
- Architecture testing guide for team

**Success Criteria**:
- CI/CD fails if code violates C4 boundaries
- At least 1 architecture violation caught automatically
- Team can write new architecture tests independently

### Phase 1 Exit Criteria (Go/No-Go Decision)

**Required Outcomes**:
- ✅ C4 diagrams auto-generate in CI/CD
- ✅ 1 feature developed using C4-first workflow successfully
- ✅ Baseline metrics collected for all 4 KPIs
- ✅ Architecture validation tests running in CI/CD
- ✅ Team satisfaction >70% (survey)
- ✅ Architectural consistency improved by >20% vs baseline

**Decision Point**: If all criteria met → Proceed to Phase 2 (Expansion)
**If not**: Iterate on tooling/workflow, extend Phase 1 by 2 weeks

---

## Phase 2: Team Expansion (Months 2-3)

**Timeline**: 2025-11-01 to 2025-12-31 (8 weeks)
**Goal**: Expand C4 adoption to all vTeam development, refine workflows

### Month 2: Full Team Adoption

**Objectives**:
- All new features use C4-first workflow
- Brownfield components get C4 diagrams
- Establish architecture review cadence

**Tasks**:
- [ ] **Week 1**: Add Component diagrams for Frontend container
  - Session Management UI, Project UI, Settings UI components
  - Update workspace.dsl with relationships
  - Generate diagrams

- [ ] **Week 2**: Add Component diagrams for Operator container
  - Project Controller, Session Controller, Resource Manager components
  - Document reconciliation loops in dynamic diagrams

- [ ] **Week 3**: Establish "Architecture Office Hours"
  - Weekly 1-hour session for questions
  - Pair programming: Update diagrams together
  - Knowledge sharing: Tips and tricks

- [ ] **Week 4**: Component-level LLM Code Generation Experiment
  - Generate code for all Frontend components from C4 diagrams
  - Measure accuracy and manual refinement time
  - Compare to baseline (prompt-only generation)

**Deliverables**:
- Complete Component diagrams for all 4 containers
- Architecture office hours schedule and recordings
- LLM generation experiment results
- Updated architecture testing suite

**Success Criteria**:
- All containers have Component diagrams
- 100% of new PRs reference architecture in description
- LLM generation accuracy >80% with C4 context

### Month 3: Measurement & Optimization

**Objectives**:
- Measure improvement vs baselines
- Optimize workflows based on learnings
- Document best practices

**Tasks**:
- [ ] **Week 1**: Metrics Review
  - Collect Month 2 data for all 4 KPIs
  - Compare to baselines
  - Identify trends and outliers

- [ ] **Week 2**: A/B Testing
  - Feature A: Developed with C4 diagrams
  - Feature B: Developed with prompts only
  - Compare: time, code quality, test coverage, architectural consistency

- [ ] **Week 3**: Process Optimization
  - Identify bottlenecks in C4 workflow
  - Streamline diagram update process
  - Automate common architecture patterns

- [ ] **Week 4**: Best Practices Documentation
  - "vTeam Architecture Playbook" document
  - Common patterns and anti-patterns
  - LLM prompting templates for C4-based generation

**Deliverables**:
- Metrics report (2-month comparison)
- A/B test results with statistical analysis
- Process optimization recommendations
- vTeam Architecture Playbook

**Success Criteria**:
- Architectural consistency improved >40% vs baseline
- LLM accuracy >85% with C4 context
- Knowledge transfer speed improved >40%
- Team satisfaction >80%

### Phase 2 Exit Criteria

**Required Outcomes**:
- ✅ All vTeam containers have complete Component diagrams
- ✅ A/B test shows measurable C4 value (>30% improvement in any metric)
- ✅ Team processes documented in Architecture Playbook
- ✅ Zero architecture drift incidents (caught by CI/CD)
- ✅ Team velocity maintained or improved vs pre-C4 baseline

**Decision Point**: If all criteria met → Proceed to Phase 3 (Ecosystem Expansion)

---

## Phase 3: Ecosystem Expansion (Months 4-6)

**Timeline**: 2026-01-01 to 2026-03-31 (12 weeks)
**Goal**: Expand C4 to other Red Hat projects, build open source community

### Month 4: Internal Red Hat Expansion

**Objectives**:
- 3-5 pilot projects in Red Hat adopt C4
- Create reusable templates and tools
- Establish Red Hat C4 Center of Excellence

**Pilot Projects (Candidates)**:
1. **OpenShift AI Console** - React/Go application
2. **InstructLab** - Python ML training pipeline
3. **Podman Desktop** - Electron application
4. **Ansible Automation Platform** - Multi-service architecture
5. **Quay.io** - Container registry service

**Tasks**:
- [ ] **Week 1-2**: Pilot Project Kickoffs
  - Workshop with each team (4 hours)
  - Create initial C4 workspace for each project
  - Pair with architects to define containers

- [ ] **Week 3**: Create Red Hat C4 Template Library
  - Template: "Kubernetes Operator Architecture"
  - Template: "React + Go Backend Web App"
  - Template: "Python ML Pipeline"
  - Template: "Multi-tenant SaaS Platform"

- [ ] **Week 4**: Establish C4 Center of Excellence
  - Slack channel: #c4-architecture
  - Weekly office hours across time zones
  - Internal blog series: "Architecture-Driven AI Development"

**Deliverables**:
- 5 pilot projects with C4 baselines
- Red Hat C4 template library (GitHub repo)
- Center of Excellence charter and schedule
- Internal blog post series (4 articles)

**Success Criteria**:
- 5 projects report positive ROI from C4
- Templates used by >50% of new projects
- 100+ engineers attend office hours

### Month 5: Open Source Community Engagement

**Objectives**:
- Publish learnings to open source community
- Contribute to upstream C4 tooling
- Engage communities Red Hat participates in

**Tasks**:
- [ ] **Week 1**: Publish Research
  - Blog post: "Why Red Hat adopted C4 for AI-assisted development"
  - Conference submission: KubeCon, DevConf.CZ, AI Engineer Summit
  - GitHub: Open source the C4 template library

- [ ] **Week 2**: Upstream Contributions
  - Structurizr DSL: Submit examples for Kubernetes/OpenShift
  - ArchUnit: Contribute Go language support improvements
  - PlantUML: Submit C4 enhancements

- [ ] **Week 3**: Community Outreach
  - CNCF presentation: "Architecture-as-Code for Cloud Native"
  - Kubernetes SIG-Architecture collaboration
  - OpenSSF: Architecture documentation best practices

- [ ] **Week 4**: Open Source Template Projects
  - Create public C4 examples for common architectures
  - "awesome-c4" list with LLM integration patterns
  - Video tutorial series: "C4 for AI-Assisted Development"

**Deliverables**:
- 2 conference talk submissions
- 3 blog posts published
- 5 upstream contributions merged
- Public template repository with 10+ examples

**Success Criteria**:
- 1,000+ views on blog posts
- 500+ stars on template repository
- 5 external projects adopt Red Hat's C4 approach

### Month 6: Ecosystem Maturity

**Objectives**:
- C4 becomes standard practice in Red Hat AI initiative
- Measure long-term impact
- Establish sustainability plan

**Tasks**:
- [ ] **Week 1**: 6-Month Metrics Review
  - Compare all KPIs vs original baselines
  - Calculate ROI (time saved, quality improvements)
  - Success stories and case studies

- [ ] **Week 2**: Sustainability Planning
  - Assign architecture owners for each major project
  - Quarterly architecture debt sprints
  - Annual C4 architecture summit

- [ ] **Week 3**: LLM Training Data
  - Package Red Hat's C4 corpus for LLM fine-tuning
  - Partner with AI teams to train models on architecture diagrams
  - Measure: Can LLM generate code from C4 alone?

- [ ] **Week 4**: Industry Collaboration
  - Partner with other companies on C4 best practices
  - Academic research collaboration (architecture-driven AI)
  - Industry standards: Propose C4 as CNCF/OpenSSF recommendation

**Deliverables**:
- 6-month impact report
- Sustainability plan document
- C4 training dataset (anonymized)
- Industry partnership MOU

**Success Criteria**:
- 50+ Red Hat projects using C4
- 90% architectural consistency across projects
- LLM code generation accuracy >90% with C4
- 60% reduction in onboarding time (proven across 20+ engineers)

### Phase 3 Exit Criteria

**Required Outcomes**:
- ✅ C4 adopted by >50 Red Hat projects
- ✅ Open source community actively using Red Hat templates
- ✅ Measurable impact: >50% improvement in key metrics
- ✅ Sustainability plan funded and resourced
- ✅ Industry recognition: Conference talks, blog citations

**Decision Point**: If all criteria met → C4 becomes standard Red Hat practice

---

## Phase 4: Long-Term Vision (Year 2+)

**Timeline**: 2026-04-01 onwards
**Goal**: C4 as industry standard for AI-assisted development

### Strategic Initiatives

#### 1. AI-Native Architecture Tools
**Vision**: LLMs that understand and generate C4 diagrams natively

**Milestones**:
- [ ] Partner with Anthropic/OpenAI on architecture-aware models
- [ ] Fine-tune LLMs on Red Hat's C4 corpus
- [ ] Build "AI Architect" agent that designs C4 diagrams from requirements
- [ ] Integrate C4 generation into Claude Code, GitHub Copilot, Cursor

#### 2. Red Hat Product Integration
**Vision**: C4 diagrams shipped with every Red Hat product

**Milestones**:
- [ ] C4 diagrams required for all major releases (docs.redhat.com)
- [ ] Customer-facing architecture diagrams in product documentation
- [ ] Sales engineering uses C4 for architecture discussions
- [ ] C4 diagrams in certification/training materials

#### 3. Open Source Leadership
**Vision**: Red Hat recognized as thought leader in architecture-driven AI

**Milestones**:
- [ ] C4 becomes CNCF recommended practice
- [ ] Red Hat engineers keynote at major conferences
- [ ] Academic research cites Red Hat's C4 methodology
- [ ] Industry adoption: >1,000 companies use Red Hat's approach

#### 4. Continuous Innovation
**Vision**: Architecture tooling evolves with AI capabilities

**Research Areas**:
- [ ] Automated architecture drift detection via ML
- [ ] Predictive architecture evolution (AI suggests next components)
- [ ] Architecture performance simulation (before coding)
- [ ] Real-time architecture validation in IDEs

---

## Success Metrics Summary

### Quantitative KPIs

| Metric | Baseline (Pre-C4) | Phase 1 Target | Phase 2 Target | Phase 3 Target |
|--------|-------------------|----------------|----------------|----------------|
| **Architectural Consistency** | <70% | 85% | 90% | 95% |
| **LLM Code Accuracy** | 50% | 70% | 85% | 90% |
| **Onboarding Speed** | 4 weeks | 3 weeks | 2 weeks | 1.5 weeks |
| **Change Impact Prediction** | 60% | 80% | 90% | 95% |
| **Architecture Drift Incidents** | 10/month | 5/month | 2/month | 0/month |
| **Test Coverage** | 65% | 75% | 85% | 90% |
| **Cross-Team Integration Issues** | 8/sprint | 6/sprint | 4/sprint | 2/sprint |

### Qualitative Indicators

**Developer Experience**:
- Team satisfaction with architecture clarity
- Ease of LLM-assisted development
- Confidence in making architectural decisions
- Collaboration efficiency across teams

**Business Impact**:
- Time-to-market for new features
- Customer-reported architecture confusion
- Technical debt accumulation rate
- Open source contribution quality

---

## Risk Mitigation

### Risk 1: Team Resistance to C4 Overhead

**Likelihood**: Medium | **Impact**: High

**Mitigation**:
- Start with lightweight adoption (Context + Container only)
- Demonstrate ROI early (Week 2 metrics)
- Automate diagram generation (reduce manual work)
- Provide templates and examples (lower learning curve)

**Contingency**: If resistance persists after Phase 1, make C4 optional but recommended

### Risk 2: Architecture-Code Drift

**Likelihood**: High | **Impact**: High

**Mitigation**:
- CI/CD automation (diagrams regenerate on every commit)
- ArchUnit tests enforce boundaries
- PR reviews check architecture alignment
- Quarterly architecture debt sprints

**Contingency**: If drift exceeds 20%, add mandatory architecture review gate

### Risk 3: LLM Accuracy Below Expectations

**Likelihood**: Medium | **Impact**: High

**Mitigation**:
- Start with simple components (prove accuracy incrementally)
- Refine prompts based on actual results
- Measure and iterate on generation templates
- Partner with AI vendors to improve architecture understanding

**Contingency**: If accuracy <60% after Phase 2, pivot to C4 for documentation only (not generation)

### Risk 4: Open Source Community Rejection

**Likelihood**: Low | **Impact**: Medium

**Mitigation**:
- Position C4 as optional, not mandatory
- Support multiple formats (PlantUML, Mermaid, Structurizr)
- Provide migration tools (existing code → C4 diagrams)
- Demonstrate value through case studies

**Contingency**: If adoption <10 external projects by Month 6, focus on Red Hat internal only

### Risk 5: Tooling Fragmentation

**Likelihood**: Medium | **Impact**: Medium

**Mitigation**:
- Standardize on Structurizr DSL + PlantUML
- Create conversion utilities between formats
- Document multi-tool workflow
- Contribute upstream to unify ecosystem

**Contingency**: If tooling chaos persists, build Red Hat-specific C4 tool

---

## Resource Requirements

### Phase 1 (Month 1)

**Engineering**:
- 1 Distinguished Engineer (Jeremy) - 40% time
- 1 Senior Engineer - 20% time
- vTeam team members - 10% time each (5 people)

**Total**: ~2 FTE-months

### Phase 2 (Months 2-3)

**Engineering**:
- 1 Distinguished Engineer - 30% time
- 2 Senior Engineers - 20% time each
- vTeam team members - 10% time each

**Total**: ~2 FTE-months

### Phase 3 (Months 4-6)

**Engineering**:
- 1 Distinguished Engineer - 20% time
- 1 Staff Engineer - 50% time (C4 Center of Excellence)
- 5 Pilot project engineers - 15% time each
- Technical writers - 25% time (2 people)

**Total**: ~4 FTE-months

### Budget

**Tooling**:
- Structurizr (open source) - $0
- PlantUML (open source) - $0
- CI/CD infrastructure - Existing Red Hat systems
- Conference travel - $10,000 (2 conferences)

**Total Budget**: <$15,000 (mostly travel)

**ROI Calculation**:
- Engineer time saved: 30 minutes/week/engineer × 25 engineers = 12.5 hours/week
- Value: 12.5 hours × $150/hour × 52 weeks = $97,500/year
- Investment: ~8 FTE-months × $15,000/month = $120,000
- **Payback period**: ~15 months

---

## Communication Plan

### Internal (Red Hat)

**Weekly**:
- vTeam standup: Architecture updates and blockers
- Metrics dashboard review

**Monthly**:
- AI Initiative leadership update (Jeremy → VP Steven Huels)
- C4 Center of Excellence newsletter

**Quarterly**:
- Red Hat Engineering All-Hands presentation
- Metrics review with stakeholders

### External (Open Source)

**Monthly**:
- Blog post on Red Hat Developer Portal
- Twitter/LinkedIn updates on progress

**Quarterly**:
- Conference submission or speaking engagement
- Open source template repository update

**Annually**:
- Major research publication or whitepaper
- Industry collaboration event

---

## Decision Points & Gates

### Gate 1: End of Phase 1 (Month 1)
**Date**: 2025-10-31
**Decision**: Proceed to Phase 2?
**Criteria**: See Phase 1 Exit Criteria above
**Decision Maker**: Jeremy Eder + vTeam team consensus

### Gate 2: End of Phase 2 (Month 3)
**Date**: 2025-12-31
**Decision**: Proceed to Phase 3?
**Criteria**: See Phase 2 Exit Criteria above
**Decision Maker**: Jeremy Eder + Steven Huels (VP AI Engineering)

### Gate 3: End of Phase 3 (Month 6)
**Date**: 2026-03-31
**Decision**: C4 becomes standard Red Hat practice?
**Criteria**: See Phase 3 Exit Criteria above
**Decision Maker**: Red Hat Engineering Leadership

---

## Immediate Next Steps (This Week)

### Jeremy's Action Items

1. **Review and validate** this roadmap
   - Confirm timelines are realistic
   - Adjust resource allocations
   - Approve pilot project list

2. **Socialize with stakeholders**
   - Share analysis document with Steven Huels (VP)
   - Present to vTeam team for feedback
   - Gauge interest from pilot project leads

3. **Setup infrastructure**
   - Create GitHub Actions workflow for diagram generation
   - Setup metrics dashboard (Google Sheets or Grafana)
   - Schedule Week 1 team workshop

4. **Commit research to repository**
   - Merge c4-research branch to main
   - Tag release: v1.0.0-c4-baseline
   - Announce to team via Slack

### Team Action Items

1. **Review architecture diagrams**
   - Open Structurizr Lite and explore workspace.dsl
   - Provide feedback: Is this accurate?
   - Identify gaps or corrections needed

2. **Block calendars**
   - 2-hour C4 workshop (Week 1)
   - Weekly architecture office hours
   - Metrics review meetings

3. **Prepare for first C4 feature**
   - Nominate feature candidate (Session Templates?)
   - Identify component boundaries
   - Plan implementation sprint

---

## Appendix: Key Documents

1. **Comprehensive Analysis**: `docs/research/c4-vs-prompting-analysis.md`
   - Full SDLC analysis with pros/cons
   - Open source adoption strategy
   - Tooling recommendations
   - Success metrics

2. **Architecture Baseline**: `architecture/workspace.dsl`
   - Complete C4 model for vTeam
   - 4 containers, 17 components
   - Deployment and dynamic diagrams

3. **Usage Guide**: `architecture/README.md`
   - How to view and edit diagrams
   - LLM integration patterns
   - Contributing guidelines

4. **This Roadmap**: `docs/research/c4-implementation-roadmap.md`
   - Phased implementation plan
   - Success criteria and gates
   - Resource requirements

---

**Questions? Feedback?**
- **Slack**: #vteam-dev or DM Jeremy Eder
- **Email**: jeder@redhat.com
- **Office Hours**: Schedule via calendar (link TBD)

**Last Updated**: 2025-09-30
**Next Review**: End of Phase 1 (2025-10-31)
