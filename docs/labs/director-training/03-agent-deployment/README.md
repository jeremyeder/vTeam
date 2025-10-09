# Lab 2: Building Modern Web Features in 60 Minutes

## What We're Building Today 🌓

You know that dark mode option in your favorite apps? The one that saves your eyes during late-night email sessions? That's what we're building.

**Why this matters**: Your teams spend weeks debating features like this. Today, you'll build one in under an hour.

By the end of this lab, you'll have:
- A working web application running on your laptop
- A professional dark mode toggle you built yourself
- A better understanding of what your development teams do every day

## No Coding Experience? No Problem!

This is a follow-along tutorial. If you can copy and paste, you can do this lab.

---

## Part 1: Getting Your Workspace Ready (8 minutes)

Think of this like setting up a new laptop - a few commands, and you're ready to go.

### Step 1.1: Copy the Starter Project

Just like using a PowerPoint template instead of starting from scratch.

**Open your terminal** and copy/paste this:

```bash
git clone https://github.com/patternfly/patternfly-react-seed
cd patternfly-react-seed
```

**What just happened?** You downloaded a pre-built web application to your computer.

---

### Step 1.2: Install What You Need

Like installing Microsoft Office before you can use Word.

**Copy and paste this** (then grab a coffee - this takes 2-3 minutes):

```bash
npm install
```

You'll see lots of text scrolling by. This is normal! It's downloading all the tools needed to run the app.

**✅ Checkpoint**: When you see "added XXX packages" you're done.

---

### Step 1.3: Start Your Application

**Copy and paste this**:

```bash
npm run start:dev
```

**You'll see**:
```
webpack compiled successfully
Project is running at http://localhost:8080
```

**Now the magic part**: Open your web browser and go to `http://localhost:8080`

✨ **You now have a working web application!**

**What you should see**:
- A clean page with "PatternFly Seed" in the header
- A sidebar on the left
- Some sample content in the middle

This is PatternFly - the same design system Red Hat uses in all our products.

---

## Part 2: Adding Dark Mode (30 minutes)

Now the fun part - we're adding a feature your customers would love.

### Step 2.1: Open the Project in Your Code Editor

**For VS Code users** (most common):

```bash
code .
```

**For other editors**: Open the `patternfly-react-seed` folder

**What you're looking at**: This is the source code. Don't worry if it looks complex - we're only touching a few files.

---

### Step 2.2: Add the Toggle Button

We'll add a button to the header that switches between light and dark modes.

**Find this file**: `src/app/AppLayout/AppLayout.tsx`

**What this file does**: Controls the layout of your entire app - the header, sidebar, everything.

**Scroll to line ~100** where you see `headerTools={`

**Add this code** right after the opening `<PageHeaderTools>` tag:

```typescript
<Button
  variant="plain"
  onClick={() => {
    const isDark = document.documentElement.classList.contains('pf-v5-theme-dark');
    if (isDark) {
      document.documentElement.classList.remove('pf-v5-theme-dark');
      localStorage.setItem('theme', 'light');
    } else {
      document.documentElement.classList.add('pf-v5-theme-dark');
      localStorage.setItem('theme', 'dark');
    }
  }}
>
  {document.documentElement.classList.contains('pf-v5-theme-dark') ? '☀️' : '🌙'}
</Button>
```

**Don't forget** to add the import at the top of the file:

```typescript
import { Button } from '@patternfly/react-core';
```

**Save the file** (Ctrl+S or Cmd+S)

**Look at your browser** - it should automatically refresh!

**You should now see**: A sun or moon emoji button in the top-right corner of your app.

**Try clicking it!** Watch what happens. Pretty cool, right?

---

### Step 2.3: Make It Remember User Choice

Right now, if you refresh the page, it forgets your preference. Let's fix that.

**Still in** `AppLayout.tsx`, add this code near the top of the component (around line 20):

```typescript
// Remember user's theme preference
React.useEffect(() => {
  const savedTheme = localStorage.getItem('theme');
  if (savedTheme === 'dark') {
    document.documentElement.classList.add('pf-v5-theme-dark');
  }
}, []);
```

**Save the file**

**Test it**:
1. Switch to dark mode
2. Refresh your browser (F5)
3. Dark mode should still be active!

🎉 **You just built a production-quality feature!**

---

### Step 2.4: Polish the Experience

Let's make the transition smooth instead of jarring.

**Create a new file**: `src/app/app.css`

**Add this CSS**:

```css
/* Smooth theme transitions */
* {
  transition: background-color 0.3s ease, color 0.3s ease;
}

/* Dark theme improvements */
.pf-v5-theme-dark {
  --pf-v5-global--BackgroundColor--100: #1a1a1a;
  --pf-v5-global--Color--100: #f0f0f0;
}
```

**Import this file** in `src/app/index.tsx` (add this line near the top):

```typescript
import './app.css';
```

**Save both files**

**Watch your app**: The theme should now fade smoothly instead of switching instantly.

---

## Part 3: See Your Results (15 minutes)

You've just built a professional feature. Let's make sure it works perfectly.

### Validation Checklist

**✅ Test 1: Does the toggle work?**
- Click the sun/moon button
- Page should smoothly transition between light and dark
- Text should stay readable in both modes

**✅ Test 2: Does it remember your choice?**
- Set it to dark mode
- Refresh the page (F5)
- Should still be dark mode

**✅ Test 3: Does it work on all pages?**
- Click "Support" in the sidebar
- Click "General"
- Theme should stay consistent across all pages

**✅ Test 4: Does it look professional?**
- No jarring color switches?
- All text is readable?
- Transitions are smooth?

**If all four tests pass**: Congratulations! You've built a feature that would typically take a developer half a day. And you did it in 30 minutes.

---

## Part 4: What This Means for Your Organization (15 minutes)

### Reflection Questions

You just experienced modern web development. Take a moment to think about:

**Speed to Market**
- You built a real feature in 30 minutes
- Your teams can prototype customer ideas in hours, not weeks
- Feedback loops go from months to days

**Questions**:
- What features are your teams debating that could be prototyped this quickly?
- How might rapid prototyping change your decision-making process?
- What if you could *show* stakeholders working features instead of PowerPoint mockups?

---

**Quality Built In**
- The toggle works smoothly out of the box
- User preferences are remembered automatically
- It looks professional without custom design work

**Questions**:
- How much time do your teams spend on "polish"?
- What if 80% of that polish came for free?
- How would this affect your quality vs. speed tradeoff discussions?

---

**This is PatternFly**
- Red Hat's design system used across all products
- Consistent experience your customers recognize
- Maintained by the same teams building OpenShift

**Questions**:
- How much time do your teams spend reinventing UI components?
- What's the value of consistency across your product portfolio?
- Could your teams focus on unique features instead of basic UI?

---

### The Bigger Picture: AI-Assisted Development

**What you just experienced** is manual web development. Now imagine:

- AI suggesting the exact code you need
- Automated testing catching bugs before you deploy
- Documentation that writes itself
- Features that adapt to user feedback in real-time

**That's what we're building** with the Ambient platform.

**The future**:
- Developers describe what they want in plain English
- AI generates the implementation
- Humans review and approve
- Ship to customers in hours, not months

---

## What You Accomplished Today

Let's be honest - most of you came into this thinking "I'm not a developer."

**But today you**:
- ✅ Set up a professional development environment
- ✅ Modified production code
- ✅ Implemented a complete user-facing feature
- ✅ Tested and validated your work
- ✅ Experienced the developer workflow firsthand

**More importantly**:
- You understand what your teams do every day
- You've seen how fast modern development can be
- You have a working example to show your stakeholders
- You can make more informed decisions about technology investments

---

## Taking This Further

### Share Your Success

**Screenshot your dark mode** and share it! Your team will be impressed.

**Show your developers** - they'll appreciate you understanding their world better.

**Ask your teams**:
- "How could we use PatternFly to speed up our roadmap?"
- "What features could we prototype in a day instead of a quarter?"
- "How can we get customer feedback earlier in the process?"

---

### Resources

**PatternFly**
- Website: https://www.patternfly.org
- Component library: Hundreds of pre-built, accessible components
- Design resources: Sketch files, design tokens, guidelines

**Red Hat Developer**
- https://developers.redhat.com
- Free tools, training, and resources
- Active community forums

**Want to go deeper?**
- Take the PatternFly tutorial: https://www.patternfly.org/get-started/develop
- Explore OpenShift: https://www.redhat.com/en/technologies/cloud-computing/openshift
- Learn about our AI strategy: https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai

---

## Troubleshooting

### "npm install" fails
**Try**: Delete the `node_modules` folder and run `npm install` again

### App won't start
**Check**: Is port 8080 already in use? Try changing it in `package.json`

### Changes don't appear
**Solution**: Hard refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)

### Dark mode button doesn't show up
**Check**: Did you import `Button` from PatternFly? Check the import at the top of the file.

### Still stuck?
**Ask the instructor** - that's what we're here for!

---

## Final Thoughts

Software development isn't magic. It's a learnable skill that gets easier with the right tools.

**You proved that today**.

The same principles apply to AI development, infrastructure automation, and every other technical challenge your teams face.

**The question isn't** "Can we do this?"

**The question is** "How fast can we move once we start?"

---

**🎉 Congratulations on completing Lab 2!**

**Next**: We'll discuss how to bring these capabilities back to your teams.

---

**Lab 2 Complete** - You're now ready for the wrap-up discussion and next steps.
