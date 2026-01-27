# Pact Message Workshop - .NET Consumer (No Kafka Knowledge Required!)

## What is This Project?

This is the **Consumer** (also called Subscriber) application. It's a service that receives product events and processes them. 

**You don't need to know anything about Kafka to understand this workshop!** We're testing the message handling logic in isolation from any messaging technology.

## The Big Picture

Imagine two applications:
- **Consumer (this project)**: Wants to receive product updates
- **Provider (separate project)**: Sends product update messages

In production, they might communicate through Kafka, RabbitMQ, or any message queue. But when testing with Pact, we don't need any of that infrastructure!

## Architecture: Ports and Adapters

We follow the "Ports and Adapters" pattern (also called Hexagonal Architecture):

```
┌──────────────────────────────────────────┐
│         Your Application                  │
│  ┌────────────────────────────────────┐  │
│  │  CORE/PORT (Domain Logic)          │  │
│  │  ProductEventProcessor             │  │
│  │  - Handles product events          │  │
│  │  - No knowledge of Kafka/queues    │  │
│  └────────────────────────────────────┘  │
│              ▲                            │
│              │                            │
│  ┌───────────┴──────────────────────────┐│
│  │  ADAPTER (Infrastructure)            ││
│  │  In Production: Kafka Consumer       ││
│  │  In Pact Tests: Pact Framework       ││
│  └──────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

### Why This Matters

By separating the business logic (Port) from the infrastructure (Adapter), we can:
1. Test the business logic without running Kafka
2. Easily switch messaging technologies later
3. Generate contracts that work across any messaging platform

## Workshop Steps

### Step 1: Understand the Consumer Code ✅ (Already Done!)

Look at [ProductEventProcessor.cs](src/ProductEventProcessor.cs):
- This is the **PORT** - it handles the business logic
- The `ProductEventHandler` method processes product events
- It doesn't know about Kafka, REST APIs, or any specific technology
- It just receives a `ProductEvent` and updates the repository

### Step 2: Write a Pact Test

Look at [ConsumerEventTests.cs](tests/ConsumerEventTests.cs):
- This test defines what messages we expect to receive
- Pact acts as the messaging system (replaces Kafka in tests)
- We describe the message structure using matchers
- When the test runs, Pact generates a **contract file**

### Step 3: Run the Test

```powershell
cd tests
dotnet test
```

**What happens:**
1. Pact creates a message matching our expectations
2. Pact passes it to our `ProductEventHandler`
3. If the handler processes it successfully, the test passes
4. Pact generates a contract file in `tests/pacts/`

### Step 4: Examine the Contract

After running the test, look in `tests/pacts/` for a JSON file named:
```
pactflow-example-consumer-dotnet-kafka-pactflow-example-provider-dotnet-kafka.json
```

This contract describes:
- What messages we expect
- What fields should be present
- What values are acceptable (using matchers)

### Step 5: Share the Contract

In a real workflow, you would:
1. Publish this contract to a Pact Broker
2. The provider team downloads it
3. The provider runs tests to verify they can produce matching messages

## Understanding the Test

### Message Structure

We expect messages like this:

```json
{
  "id": "some-uuid-1234-5678",
  "type": "Product Range",
  "name": "Some Product",
  "version": "v1",
  "event": "UPDATED"
}
```

### Pact Matchers

- `Match.Type("example")` - Any value of the same type is OK
- `Match.Regex("UPDATED", "^(CREATED|UPDATED|DELETED)$")` - Must match the regex pattern

### Metadata

We also specify metadata:
```csharp
.WithMetadata("kafka_topic", "products")
```

This tells the provider which Kafka topic to use. But remember: in our Pact tests, we never actually use Kafka!

## Common Test Scenarios

### Test 1: Happy Path ✅
The test we have tests a successful message processing.

### Test 2: Invalid Event Type (Try This!)

Modify the test to expect an event type that doesn't exist:

```csharp
@event = Match.Regex("INVALID","^(CREATED|UPDATED|DELETED)$")
```

Run the test - it should fail because our handler throws an error for unknown events.

### Test 3: Missing Fields (Try This!)

Comment out the `id` field in the test. The handler will fail because it expects an id.

## Key Concepts

### Consumer-Driven Contracts

The **consumer** (this project) writes tests that define expectations. This is powerful because:
- Consumers know what they need
- Providers can't make breaking changes without knowing
- No more "it works on my machine" integration problems

### No Infrastructure Required

Notice what we DON'T need:
- ❌ Running Kafka
- ❌ Running the provider application
- ❌ Integration test environment
- ✅ Just our code + Pact framework

### Fast Feedback

These tests run in milliseconds because they're just unit tests. No network calls, no containers, no waiting.

## Next Steps

After completing the consumer:
1. Look at the provider project (provider-dotnet-kafka)
2. The provider will verify it can produce messages matching our contract
3. This confirms both sides are compatible - without integration tests!

## Project Structure

```
consumer-dotnet-kafka/
├── src/
│   ├── ProductEventProcessor.cs   ← The "Port" - business logic
│   ├── Repositories/
│   │   ├── Product.cs             ← Domain model
│   │   └── ProductRepository.cs   ← Data storage
│   └── consumer.csproj
├── tests/
│   ├── ConsumerEventTests.cs      ← Pact test (you are here!)
│   ├── tests.csproj
│   └── pacts/                     ← Generated contracts appear here
└── WORKSHOP-README.md             ← This file
```

## Troubleshooting

### Test fails with "Unable to process event"
Your message doesn't match what the handler expects. Check the event field contains CREATED, UPDATED, or DELETED.

### No pact file generated
The test must pass for the contract to be written. Fix any test failures first.

### Want to see the actual message?
Add console output in the test or look at the test output - Pact shows the exact message it generated.

## Learning Resources

- [Pact Documentation](https://docs.pact.io/)
- [Pact .NET](https://github.com/pact-foundation/pact-net)
- [Contract Testing Introduction](https://docs.pact.io/getting_started/how_pact_works)

## Summary

🎉 **Congratulations!** You've learned:
- How to write consumer Pact tests for message-based systems
- The Ports and Adapters pattern for testable code
- How to use Pact matchers for flexible contracts
- How to test message handling without infrastructure

Next: Move to the provider project to see how they verify this contract!
