# Event-Driven Consumer - .NET Kafka Consumer

![GitHub Repo](https://github.com/Dom-Crosbie/EventDrivenConsumer)

## What is This?

A .NET 8 consumer application that processes product events using **Contract Testing with Pact**. This project demonstrates how to test message-driven architectures without needing actual messaging infrastructure.

## Key Features

- ✅ Message-based contract testing with Pact
- ✅ Clean architecture (Ports & Adapters pattern)
- ✅ No Kafka required for testing
- ✅ PactFlow integration for contract sharing
- ✅ CI/CD ready with can-i-deploy checks

## Quick Start

### Prerequisites

- .NET 8.0 SDK or higher
- Docker (for pact-broker CLI)
- PactFlow account: https://dom-crosbie.pactflow.io

### Run Tests

```powershell
# Run consumer tests and generate contract
cd tests
dotnet test
```

The contract file will be generated in `tests/pacts/`

### Publish Contract to PactFlow

```powershell
# Publish with default settings
.\publish-pact.ps1

# Publish with custom version and branch
.\publish-pact.ps1 -ConsumerVersion "1.2.0" -Branch "feature/new-api"

# Publish with a tag
.\publish-pact.ps1 -ConsumerVersion "1.2.0" -Branch "main" -Tag "prod"
```

### Check if Safe to Deploy

```powershell
# Check if this version can be deployed to production
.\can-i-deploy.ps1 -ConsumerVersion "1.2.0"

# Check specific branch
.\can-i-deploy.ps1 -Branch "new-feature"
```

## Project Structure

```
consumer-dotnet-kafka/
├── src/                              # Application code
│   ├── ProductEventProcessor.cs      # Core business logic (Port)
│   ├── Controllers/                  # API endpoints
│   └── Repositories/                 # Data layer
├── tests/                            # Pact consumer tests
│   ├── ConsumerEventTests.cs         # Contract test definitions
│   └── pacts/                        # Generated contract files
├── publish-pact.ps1                  # Publish contracts to PactFlow
├── can-i-deploy.ps1                  # Verify deployment safety
└── WORKSHOP-README.md                # Detailed learning guide
```

## PowerShell Scripts

| Script | Purpose | Common Usage |
|--------|---------|--------------|
| `publish-pact.ps1` | Run tests and publish contract to PactFlow | `.\publish-pact.ps1 -ConsumerVersion "1.0.0" -Branch "main"` |
| `can-i-deploy.ps1` | Check if version is safe to deploy | `.\can-i-deploy.ps1 -ConsumerVersion "1.0.0"` |
| `demo-workflow.ps1` | Interactive demo of contract testing workflow | `.\demo-workflow.ps1` |
| `quick-reference.ps1` | Display quick reference guide | `.\quick-reference.ps1` |

### Script Details

Each script includes comprehensive help documentation. View it with:
```powershell
Get-Help .\publish-pact.ps1 -Detailed
Get-Help .\can-i-deploy.ps1 -Detailed
```

All scripts support alternative execution via:
- **pact-broker CLI** (install from Ruby gems)
- **Docker** (pactfoundation/pact-cli image)
- **Direct commands** (see script headers for examples)

## Workflow

```
1. Write Consumer Test → 2. Generate Contract → 3. Publish to PactFlow
                                                        ↓
                                                 Provider Verifies
                                                        ↓
                                           4. can-i-deploy Check
                                                        ↓
                                                   5. Deploy ✅
```

## Learning Resources

- **New to Contract Testing?** Read [WORKSHOP-README.md](WORKSHOP-README.md) for a step-by-step guide
- **Pact Documentation:** https://docs.pact.io/
- **PactFlow:** https://pactflow.io/

## Configuration

Edit scripts to update broker settings:

```powershell
$BrokerBaseUrl = "https://dom-crosbie.pactflow.io"
$BrokerToken = "YOUR_TOKEN_HERE"
```

## Support

For issues or questions about this project, please refer to the workshop documentation or Pact community resources.
