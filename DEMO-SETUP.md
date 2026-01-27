# Contract Testing Demo Setup Guide

## 🎯 Demo Goal
Demonstrate how **can-i-deploy** checks prevent breaking changes from reaching production.

## 📋 What You'll Show

1. ✅ **Successful can-i-deploy**: Current version passes verification
2. ❌ **Failed can-i-deploy**: Breaking change fails verification
3. 💡 **Value**: Contract testing catches issues before production

---

## 🚀 Quick Setup (5 minutes)

### Option 1: Use the Interactive Script
```powershell
.\demo-workflow.ps1
```
This will guide you through the entire demo automatically!

### Option 2: Manual Setup (for more control)

#### Step 1: Publish Current Version with Tag
```powershell
.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Branch "main" -Tag "new-feature"
```

**Expected output**: ✅ Tests pass, contract published

#### Step 2: Verify Can Deploy (Should Pass)
```powershell
.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"
```

**Expected output**: ✅ Safe to deploy (if provider has verified)

> **Note**: If this fails, the provider hasn't verified yet. Either:
> - Wait for provider verification
> - Use a version that's already verified
> - Continue demo anyway (it still shows the concept)

---

## 🎭 During Your Demo

### Part 1: Show Successful can-i-deploy ✅

**Say**: "We've published our contract with version 1.0.0 and tagged it as 'new-feature'. Let's check if it's safe to deploy."

```powershell
.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"
```

**Point out**:
- The matrix shows all provider verifications
- All checks passed ✅
- Safe to deploy to production

---

### Part 2: Create a Breaking Change ❌

**Say**: "Now let's simulate adding a new event type that the provider doesn't support yet."

1. Open: `tests/ConsumerEventTests.cs`

2. Find line ~31:
```csharp
@event = Match.Regex("UPDATED", "^(CREATED|UPDATED|DELETED)$")
```

3. Change to:
```csharp
@event = Match.Regex("ARCHIVED", "^(CREATED|UPDATED|DELETED|ARCHIVED)$")
```

**Explain**: "We're adding a new 'ARCHIVED' event type. The provider doesn't support this yet, so it's a breaking change."

---

### Part 3: Publish Breaking Change

**Say**: "Let's publish this breaking change as version 1.1.0."

```powershell
.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Branch "main" -Tag "new-feature"
```

**Point out**:
- Tests still pass locally ✅
- Contract is successfully published
- **But** the provider hasn't verified this new contract

---

### Part 4: Show Failed can-i-deploy ❌

**Say**: "Now let's check if version 1.1.0 is safe to deploy."

```powershell
.\can-i-deploy.ps1 -ConsumerVersion "1.1.0"
```

**Expected output**: ❌ NOT safe to deploy!

**Explain**:
- The provider hasn't verified this new contract
- We have unverified consumer expectations
- **This prevents us from deploying a breaking change!**
- Provider needs to update their code first

---

## 🎓 Key Talking Points

### Why This Matters
- **Without Contract Testing**: Breaking changes discovered in production 💥
- **With Contract Testing**: Breaking changes caught before deployment ✅
- **Result**: Faster, safer deployments

### The Workflow
1. Consumer defines expectations (contract test)
2. Provider verifies they meet expectations
3. can-i-deploy checks both sides are compatible
4. Deploy only when safe

### Time & Cost Savings
- ⚡ Fast: Tests run in milliseconds
- 💰 Cheap: No integration environments needed
- 🛡️ Safe: Catch issues before production
- 🤝 Better: Clear communication between teams

---

## 🔧 Alternative Demo Paths

### Demo Path A: Focus on Success Flow
- Show only successful can-i-deploy
- Explain how it works
- Show PactFlow dashboard

### Demo Path B: Focus on Preventing Failures  
- Start with breaking change
- Show can-i-deploy failure
- Explain how this prevents production issues

### Demo Path C: Full Workflow (Recommended)
- Show success case first
- Then show failure case
- Contrast the two scenarios

---

## 📊 Visual Aids

### Show in PactFlow Dashboard
- Navigate to: https://dom-crosbie.pactflow.io
- Show the matrix view
- Point out:
  - Consumer versions
  - Provider verifications
  - Compatible versions (green)
  - Unverified versions (red/yellow)

### Show in Terminal
- Color-coded output
- ✅ Green for success
- ❌ Red for failure
- Clear, actionable messages

---

## 🎬 Practice Run Script

```powershell
# 1. Setup (before demo)
.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Tag "new-feature"

# 2. During demo - Success
.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"
# Talk about why it passed

# 3. Make breaking change
# Edit ConsumerEventTests.cs (change UPDATED to ARCHIVED)

# 4. During demo - Publish breaking change
.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Tag "new-feature"

# 5. During demo - Failure
.\can-i-deploy.ps1 -ConsumerVersion "1.1.0"
# Talk about why it failed and what to do next
```

---

## ⚠️ Troubleshooting

### Provider Hasn't Verified Yet
- **Solution**: Use a different version that's already verified
- **Or**: Still demonstrate the concept (explain this is expected in real workflow)

### Tests Fail
- **Check**: Syntax in ConsumerEventTests.cs
- **Reset**: Revert changes and try again
- **Backup**: Have a working version committed

### Docker Issues
- **Alternative**: Install pact-broker CLI via Ruby gems
- **Or**: Use pre-recorded screenshots

---

## 📝 Demo Checklist

Before your demo:
- [ ] Tests pass locally
- [ ] Version 1.0.0 is published
- [ ] PactFlow dashboard accessible
- [ ] Scripts tested and working
- [ ] Backup plan if provider not verified
- [ ] Know your talking points
- [ ] Practice timing (5-10 minutes)

During your demo:
- [ ] Explain contract testing briefly
- [ ] Show successful can-i-deploy
- [ ] Make breaking change live
- [ ] Show failed can-i-deploy
- [ ] Explain the value

After your demo:
- [ ] Share PactFlow dashboard link
- [ ] Share GitHub repo link
- [ ] Answer questions

---

## 💡 Pro Tips

1. **Keep it Simple**: Focus on the "can-i-deploy" check, not implementation details
2. **Show Don't Tell**: Run the commands live, show real output
3. **Contrast**: Make the before/after clear
4. **Connect to Pain**: Mention production incidents from breaking changes
5. **Be Prepared**: Have a backup plan if something doesn't work

---

## 🔗 Useful Links for Your Demo

- **GitHub Repo**: https://github.com/Dom-Crosbie/EventDrivenConsumer
- **PactFlow Dashboard**: https://dom-crosbie.pactflow.io
- **Pact Docs**: https://docs.pact.io

---

## 🎉 You're Ready!

Run through the practice script once, then you're good to go. The scripts handle all the complexity - you just need to explain what's happening!

**Good luck with your demo! 🚀**
