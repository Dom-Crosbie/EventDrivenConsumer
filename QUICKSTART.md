# 🚀 QUICK START - Contract Testing Demo

## ⚡ 30-Second Start

```powershell
# Run the automated demo
.\full-demo.ps1
```

That's it! The script does everything automatically.

---

## 🎯 What You'll See

1. ✅ Kafka starts/verified
2. ✅ Consumer app starts on http://localhost:5001
3. ✅ Test events sent to Kafka
4. ✅ Events processed by consumer
5. ✅ Working contract published (v1.0.0)
6. ✅ can-i-deploy check passes
7. 🔴 You make a breaking change
8. 🔴 New contract published (v1.1.0)
9. ❌ can-i-deploy BLOCKS deployment
10. 🎉 Breaking change caught!

---

## 📋 Manual Demo (If You Want Control)

### 1. Start Infrastructure

```powershell
# Start Kafka
.\start-kafka.ps1
```

### 2. Start Consumer App

```powershell
# In Terminal 1
cd src
dotnet run
```

Wait for: `Application started. Press Ctrl+C to shut down.`

### 3. Send Events & Verify

```powershell
# In Terminal 2
.\send-event.ps1 -Mode quick

# View processed events
start http://localhost:5001/api/events
```

### 4. Monitor Kafka (Optional)

```powershell
# In Terminal 3
.\monitor-kafka.ps1
```

### 5. Contract Testing Demo

```powershell
# Publish working version
.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Tag "demo"

# Check deployment safety (should pass)
.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"

# Make breaking change in tests/ConsumerEventTests.cs
# Change "UPDATED" to "ARCHIVED"

# Publish breaking version
.\publish-pact.ps1 -ConsumerVersion "1.1.0" -Tag "demo"

# Check deployment safety (should FAIL)
.\can-i-deploy.ps1 -ConsumerVersion "1.1.0"
```

---

## 🐛 Troubleshooting

### Consumer 404 Error

**Problem:** http://localhost:5001/api/events returns 404

**Fix:**
1. Check consumer is running: Look for "Application started" message
2. Verify correct port: Should be 5001
3. Try `/products` endpoint first: http://localhost:5001/products

### Kafka Not Running

```powershell
.\start-kafka.ps1
```

### Consumer Won't Start

```powershell
cd src
dotnet clean
dotnet build
dotnet run
```

### Build Errors

```powershell
# Restore packages
cd src
dotnet restore

# Clean build
dotnet clean
dotnet build
```

---

## 📊 Endpoints Reference

Once consumer is running:

| Endpoint | Purpose | Example |
|----------|---------|---------|
| http://localhost:5001/products | List all products | GET request |
| http://localhost:5001/product/{id} | Get single product | http://localhost:5001/product/prod-001 |
| http://localhost:5001/api/events | View processed events | Shows what came from Kafka |

---

## 🎬 Demo Flow Visualization

```
┌─────────────────────┐
│   Start Kafka       │
│  .\start-kafka.ps1  │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  Start Consumer     │
│   cd src            │
│   dotnet run        │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│   Send Events       │
│ .\send-event.ps1    │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  Verify @ :8080     │
│    /api/events      │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│ Publish Contract    │
│  v1.0.0 (working)   │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  can-i-deploy?      │
│  ✅ SAFE (v1.0.0)   │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  Breaking Change    │
│ Add ARCHIVED event  │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│ Publish Contract    │
│ v1.1.0 (breaking)   │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  can-i-deploy?      │
│ ❌ BLOCKED (v1.1.0) │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│   🎉 SUCCESS!       │
│ Breaking change     │
│ caught before prod  │
└─────────────────────┘
```

---

## 💡 Pro Tips

1. **Use automated demo first** - Run `.\full-demo.ps1` to see the whole flow
2. **Keep PactFlow open** - Watch the dashboard during demo
3. **Monitor Kafka** - Shows real events flowing
4. **Explain as you go** - Don't just run commands, explain why
5. **Have backup** - Screenshots if something breaks

---

## 📚 More Info

- **Full Guide:** [FULL-DEMO-GUIDE.md](FULL-DEMO-GUIDE.md)
- **Setup Details:** [DEMO-SETUP.md](DEMO-SETUP.md)  
- **Quick Reference:** `.\quick-reference.ps1`

---

## ✅ Ready to Present!

You now have:
- ✅ Automated demo script
- ✅ Kafka monitoring tools
- ✅ Clear demo flow
- ✅ Contract testing proof
- ✅ Breaking change detection

**Run `.\full-demo.ps1` and you're good to go! 🚀**
