# Lab 3: Your First AI-Generated Feature

## What We're Building Today 🌓

You know that dark mode option in your favorite apps? The one that saves your eyes during late-night email sessions?

In this lab, you're going to watch AI build that feature for you. No coding. No copy/paste. Just describe what you want, and the system does the work.

**Why this matters**: Your teams spend days implementing features like this. Today, you'll see AI do it in minutes.

By the end of this lab, you'll have:
- Created a feature request using natural language
- Watched AI generate working code automatically
- Reviewed the AI's implementation in a draft branch
- Understood how AI-assisted development transforms velocity

## The New Way to Build Software

Traditional development:
1. Write detailed requirements
2. Developer codes for 2-3 days
3. Code review takes another day
4. QA finds issues, back to step 2
5. Ship after 1-2 weeks

**With vTeam**:
1. Describe what you want in plain English (5 minutes)
2. AI generates working code (10 minutes)
3. Review the draft branch (15 minutes)
4. Ship the same day

Let's see it in action.

---

## Part 1: Create Your Feature Request (10 minutes)

### Step 1.1: Open the vTeam Web Interface

Your instructor will provide the URL for your training environment.

**Navigate to**: `https://vteam.your-training-cluster.com`

**You should see**:
- Clean dashboard showing recent RFEs
- "New RFE" button in the top right
- List of your team's projects

---

### Step 1.2: Start a New RFE

**Click**: "New RFE" button

**You'll see a chat interface**. This is where you describe what you want in plain English.

**Type this** (or describe your own dark mode vision):

```
I want to add a dark mode toggle to the PatternFly React Seed app.

The button should:
- Appear in the top-right header
- Show a sun icon in dark mode, moon icon in light mode
- Smoothly transition between themes
- Remember the user's preference across sessions

The app should use PatternFly's built-in dark theme classes.
```

**Hit Enter** and watch what happens.

---

### Step 1.3: Watch the AI Council at Work

You'll see multiple AI agents start working on your request:

**Parker (Product Manager)**:
- Analyzing business value
- Identifying user benefits
- Scoring priority

**Archie (Architect)**:
- Reviewing technical approach
- Checking PatternFly compatibility
- Identifying dependencies

**Stella (Staff Engineer)**:
- Planning implementation
- Estimating complexity
- Breaking down tasks

**This takes about 2-3 minutes.** Watch the conversation unfold in real-time.

**What you're seeing**: AI agents collaborating just like your real teams do. They debate, question each other, and refine the approach before any code is written.

---

### Step 1.4: Review the Refined RFE

Once the agents finish, you'll see:

**✅ Business Case** (from Parker):
- User value score: 8/10
- Expected adoption: High
- Strategic alignment: Accessibility improvement

**✅ Technical Plan** (from Archie):
- Implementation: React state + localStorage
- PatternFly integration: Built-in theme classes
- Risk assessment: Low complexity

**✅ Implementation Estimate** (from Stella):
- Time: 2-3 hours for manual development
- AI generation time: ~10 minutes
- Complexity: Medium

**Click "Approve RFE"** to move to implementation.

---

## Part 2: AI Generates Your Code (15 minutes)

### Step 2.1: Trigger Implementation

After approving the RFE, you'll see:

**"Implementation Mode"** panel with options:
- **Generate Code**: AI writes the implementation
- **Manual Implementation**: Traditional developer workflow
- **Hybrid**: AI scaffolds, developer finishes

**Click "Generate Code"**

---

### Step 2.2: Watch the Implementation

The vTeam system now:

1. **Creates a draft branch** (`feature/dark-mode-toggle-ai-generated`)
2. **Generates the code** based on the refined RFE
3. **Runs tests** to verify it works
4. **Creates a pull request** with full documentation

**You'll see real-time logs**:

```
[00:02] Creating feature branch...
[00:15] Analyzing codebase structure...
[00:45] Generating AppLayout.tsx modifications...
[01:30] Adding theme persistence logic...
[02:00] Creating CSS transitions...
[02:30] Running linters and formatters...
[03:00] Running test suite...
[03:45] All tests passing ✅
[04:00] Creating pull request...
[04:15] Done! Review at: https://github.com/your-org/patternfly-react-seed/pull/42
```

**This is production-quality code**, not a prototype. The AI:
- Follows your team's coding standards
- Writes tests
- Adds proper documentation
- Handles edge cases

---

### Step 2.3: Review the Generated Code

**Click the pull request URL** from the logs.

**You'll see**:

**Files Changed** (typically 3-4 files):
- `src/app/AppLayout/AppLayout.tsx` - Dark mode button component
- `src/app/app.css` - Smooth theme transitions
- `src/app/index.tsx` - CSS import
- `README.md` - Documentation update

**Review the code quality**:
- Proper TypeScript types
- React hooks best practices
- PatternFly component usage
- Accessibility attributes

**Check the tests**:
- Theme toggle functionality
- localStorage persistence
- Smooth transitions

**Read the PR description**:
- Clear explanation of changes
- Testing instructions
- Screenshots (AI-generated if applicable)

---

### Step 2.4: Test the Implementation

The vTeam system has already deployed a preview environment.

**Click**: "View Preview" button in the PR

**You should see**:
- The PatternFly React Seed app running
- A sun/moon button in the top-right
- Clicking it smoothly transitions between themes
- Refreshing the page maintains your choice

**Try it yourself**:
1. Click the dark mode toggle
2. Watch the smooth transition
3. Refresh the page (F5)
4. Dark mode persists!

**This is production-ready code.** Ship it today if you want.

---

## Part 3: What Just Happened?

Let's pause and reflect on what you experienced:

### Traditional Development Timeline
- **Day 1**: PM writes requirements, schedules refinement meeting
- **Day 2**: Refinement meeting with 6-8 people (2 hours)
- **Day 3**: Developer implements feature (4-6 hours)
- **Day 4**: Code review, revisions (2-3 hours)
- **Day 5**: QA testing, bug fixes
- **Day 6-7**: Final review and merge

**Total time**: 5-7 days, 15-20 person-hours

### AI-Assisted Development Timeline
- **Minute 0-5**: You describe the feature in natural language
- **Minute 5-8**: AI agents refine requirements automatically
- **Minute 8-12**: AI generates production-quality code
- **Minute 12-25**: You review and approve

**Total time**: 25 minutes, 1 person-hour

### The Difference

**Speed**: 30x faster end-to-end
**Quality**: Same or better (consistent standards, comprehensive tests)
**Cost**: ~$2 in AI costs vs. $400-600 in engineering time
**Iteration**: Try 3 different approaches in the time one traditional spike takes

**Most importantly**: Your engineers can focus on truly complex problems while AI handles the routine implementation work.

---

## What You Accomplished Today

You just:
- ✅ Created a feature request using natural language
- ✅ Watched multi-agent AI refine requirements automatically
- ✅ Saw AI generate production-quality code in minutes
- ✅ Reviewed working code in a real pull request
- ✅ Tested a deployed preview environment

**More importantly**:
- You understand how AI transforms development velocity
- You've seen the quality of AI-generated code
- You know what "AI-assisted development" actually means
- You can evaluate whether this fits your team's workflow

---

## Taking This Back to Your Teams

### Questions to Ask Your Engineering Leaders

**Velocity**:
- How many features are sitting in "refinement" right now?
- What if we could refine and implement in the same day?
- Which features could we build with AI that we don't have time for today?

**Quality**:
- How consistent are our coding standards across developers?
- How often do we skip tests because of time pressure?
- What if every feature came with comprehensive tests by default?

**Capacity**:
- What if junior engineers could implement at senior engineer quality?
- How many staff engineers are writing boilerplate code instead of solving hard problems?
- What strategic work are we not doing because everyone's heads-down on implementation?

### Next Steps

**This Week**:
- Share this experience with your teams
- Identify 2-3 features that could be AI-generated
- Calculate the ROI for your specific context

**This Month**:
- Run a pilot with one team
- Measure velocity improvement
- Iterate on prompts and workflows

**This Quarter**:
- Expand to multiple teams
- Build your library of effective RFE patterns
- Train engineers on AI-assisted workflows

---

## Additional Resources

**vTeam Documentation**:
- Platform architecture: `docs/architecture/README.md`
- RFE workflow guide: `docs/workflows/rfe-creation.md`
- Best practices: `docs/best-practices/ai-prompts.md`

**PatternFly**:
- Component library: https://www.patternfly.org
- Dark theme documentation: https://www.patternfly.org/v4/get-started/develop#dark-theme

**Questions?**:
Ask your instructor or post in the training Slack channel.

---

**🎉 Congratulations on completing Lab 3!**

You've now experienced the full AI-assisted development workflow. In the wrap-up session, we'll discuss how to bring this capability to your organization.

---

**Lab 3 Complete** - You're ready for the final discussion and Q&A.
