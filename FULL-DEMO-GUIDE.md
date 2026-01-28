# Full Contract Testing Demo Guide

## 🎯 What This Demo Shows

1. **Consumer Application** processes events from Kafka
2. **Contract Tests** define what events consumer expects
3. **Working Contract** is published (v1.0.0) and verified
4. **Breaking Change** is introduced (v1.1.0) - new event type
5. **can-i-deploy** catches the incompatibility and PREVENTS deployment
6. **Value**: Breaking changes caught before production!

---

## 🚀 Quick Start - Automated Demo

```powershell
.\full-demo.ps1
```

This script handles everything automatically and guides you through each step!

---

## 📋 Manual Demo Steps

### Prerequisites

```powershell
# Ensure Kafka is running
.\start-kafka.ps1

# Verify Kafka is up
docker ps | Select-String "demo-kafka"
```

---

### Part 1: Working System (v1.0.0)

#### Step 1: Start Consumer Application

```powershell
# Terminal 1: Start the consumer
cd src
dotnet run
```

**Wait for:** "Application started" message

The consumer will:
- Connect to Kafka at `localhost:9092`
- Subscribe to `products` topic
- Process incoming events
- Store them in memory

#### Step 2: Monitor Kafka (Optional)

```powershell
# Terminal 2: Monitor Kafka events
.\monitor-kafka.ps1
```

This shows all events in real-time as they're published.

#### Step 3: Send Test Events

```powershell
# Terminal 3: Send events
.\send-event.ps1 -Mode quick
```

**What happens:**
- 3 product events sent to Kafka
- Consumer receives and processes them
- Events stored in ProductRepository

#### Step 4: Verify Processing

```powershell
# Check processed events
curl http://localhost:8080/api/events

# Or open in browser
start http://localhost:8080/api/events
```

**Expected Response:**
```json
[
  {
    "id": "prod-001",
    "type": "Electronics",
    "name": "Laptop Pro",
    "version": "v1.0",
    "event": "CREATED",
    "timestamp": "2026-01-28T...",
    "processed": true,
    "failed": false
  },
  ...
]
```

---

### Part 2: Contract Testing - Working Version

#### Step 5: Publish Working Contract

```powershell
.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Branch "main" -Tag "demo"
```

**What this does:**
1. Runs consumer contract tests
2. Generates a Pact file defining expected events
3. Publishes to PactFlow broker
4. Tags as version 1.0.0

**Expected Output:**
```
✅ Consumer tests passed!
✅ Found pact file
✅ Successfully published contract to PactFlow!
```

#### Step 6: Check Deployment Safety

```powershell
.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"
```

**Expected Result:** 
- ✅ **SAFE TO DEPLOY** (if provider has verified)
- ❌ **NOT SAFE** (if provider hasn't verified yet - this is OK for demo)

**What this checks:**
- Has the provider verified this contract?
- Are all dependencies compatible?
- Is it safe to deploy to production?

---

### Part 3: Breaking Change (v1.1.0)

#### Step 7: Modify Consumer Expectations

**Goal:** Consumer wants to support a new "ARCHIVED" event type that the provider doesn't support yet.

**File:** `tests/ConsumerEventTests.cs`

**Find this line (~31):**
```csharp
@event = Match.Regex("UPDATED", "^(CREATED|UPDATED|DELETED)$")
```

**Change to:**
```csharp
@event = Match.Regex("ARCHIVED", "^(CREATED|UPDATED|DELETED|ARCHIVED)$")
```

**Why this breaks:**
- Consumer now expects ARCHIVED events
- Provider doesn't know about ARCHIVED
- This is a **breaking change** in expectations

#### Step 8: Publish Breaking Change

```powershell
.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Branch "main" -Tag "demo"
```

**What happens:**
- Tests pass locally (consumer code handles it)
- New contract published as v1.1.0
- Contract now includes ARCHIVED in expectations

#### Step 9: Check Deployment Safety (Breaking Change!)

```powershell
.\can-i-deploy.ps1 -ConsumerVersion "1.1.0"
```

**Expected Result:** ❌ **NOT SAFE TO DEPLOY!**

**Why it fails:**
- Provider hasn't verified the new contract
- Provider doesn't support ARCHIVED event yet
- Deploying would break the integration

**Output shows:**
```
❌ NOT SAFE TO DEPLOY!
Provider verifications are missing or have failed.
Do NOT deploy this version to production yet.
```

---

## 🎓 Demo Talking Points

### What Just Happened?

1. **Version 1.0.0:**
   - Consumer and provider have compatible contract
   - can-i-deploy says ✅ safe
   - Can deploy to production

2. **Version 1.1.0:**
   - Consumer added new requirement (ARCHIVED event)
   - Provider doesn't support it yet
   - can-i-deploy says ❌ not safe
   - **Prevented a production break!**

### The Value

**Without Contract Testing:**
- Consumer deploys v1.1.0
- Expects ARCHIVED events
- Provider sends events without ARCHIVED
- 💥 Integration breaks in production
- Incidents, rollbacks, emergency fixes

**With Contract Testing:**
- Consumer publishes new contract
- can-i-deploy checks compatibility
- ❌ Blocks deployment automatically
- Provider team is notified
- Provider updates code first
- Provider verifies new contract
- ✅ Now safe for consumer to deploy
- Zero downtime, smooth release

### The Workflow

```
Consumer Side:
1. Make code changes
2. Update contract test
3. Run tests (pass locally)
4. Publish contract to broker
5. Run can-i-deploy
   ❌ BLOCKED - wait for provider

Provider Side (notified of new contract):
1. Review new consumer expectations
2. Update provider code to support ARCHIVED
3. Run provider verification tests
4. Tests pass - contract verified
5. Deploy provider changes

Consumer Side (continued):
6. Run can-i-deploy again
   ✅ SAFE - provider verified!
7. Deploy consumer changes
8. Both systems compatible ✅
```

---

## 🔧 Monitoring Tools

### Monitor Kafka Events

```powershell
# Real-time event monitoring
.\monitor-kafka.ps1
```

### Monitor Consumer Application

```powershell
# Check consumer health
curl http://localhost:8080/products

# View processed events
curl http://localhost:8080/api/events

# View specific product
curl http://localhost:8080/product/prod-001
```

### Monitor PactFlow

Open in browser:
```
https://dom-crosbie.pactflow.io
```

View:
- Contract matrix
- Version compatibility
- Verification status
- Deployment status

---

## 🐛 Troubleshooting

### Consumer Won't Start

**Issue:** `dotnet run` fails

**Solutions:**
```powershell
# Check Kafka is running
docker ps | Select-String "kafka"

# If not running
.\start-kafka.ps1

# Check port 8080 is free
netstat -ano | findstr :8080

# Clean and rebuild
cd src
dotnet clean
dotnet build
```

### 404 on /api/events

**Issue:** Endpoint returns 404

**Check:**
1. Is consumer running? (should see console output)
2. Correct port? (8080, not 5000)
3. Correct URL? `http://localhost:8080/api/events`

**Verify:**
```powershell
# Check if app is responding
curl http://localhost:8080/products
```

### can-i-deploy Always Fails

**Issue:** Even v1.0.0 shows not safe

**Reason:** Provider hasn't verified ANY contract yet

**This is normal if:**
- First time running demo
- Provider app not set up yet
- Provider verification hasn't run

**Still demonstrates the concept:**
- Show that can-i-deploy blocks unsafe deployments
- Explain provider verification is required

---

## 🎬 Presentation Script

**Slide 1: The Problem**
> "When microservices evolve independently, integration breaks happen in production."

**Slide 2: Traditional Testing**
> "Integration tests are slow, brittle, and expensive to maintain."

**Slide 3: Contract Testing**
> "Consumer defines expectations. Provider verifies they can meet them. No integration environment needed!"

**[DEMO TIME]**

**Part 1:** (5 minutes)
1. Show consumer processing events
2. Show contract test
3. Publish and can-i-deploy succeeds

**Part 2:** (5 minutes)
1. Make breaking change live
2. Publish new contract
3. can-i-deploy blocks deployment
4. Show PactFlow matrix

**Slide 4: The Value**
> "Breaking changes caught before production. Fast feedback. Safe deployments."

---

## 📊 Key Metrics to Highlight

- **Speed:** Tests run in milliseconds (vs minutes for integration tests)
- **Cost:** No integration environments needed
- **Safety:** Prevents 100% of contract-breaking changes
- **Developer Experience:** Fast feedback, clear errors

---

## 🎉 Demo Checklist

Before Demo:
- [ ] Kafka running: `.\start-kafka.ps1`
- [ ] PactFlow accessible
- [ ] Know your PactFlow URL
- [ ] Practice timing (10-15 minutes)
- [ ] Have backup screenshots

During Demo:
- [ ] Show real events in Kafka
- [ ] Run tests live
- [ ] Make breaking change live
- [ ] Show can-i-deploy blocking deployment
- [ ] Show PactFlow matrix

After Demo:
- [ ] Share GitHub repo
- [ ] Share PactFlow dashboard
- [ ] Answer questions

---

## 🔗 Resources

- **GitHub:** https://github.com/Dom-Crosbie/EventDrivenConsumer
- **PactFlow:** https://dom-crosbie.pactflow.io
- **Pact Docs:** https://docs.pact.io/

---

**Ready to demo! 🚀**
