using System.Threading.Tasks;
using PactNet;
using PactNet.Output.Xunit;
using Xunit;
using Xunit.Abstractions;
using Match = PactNet.Matchers.Match;
using Products;

namespace Consumer.Tests
{
    // STEP 2: Create Consumer Pact Test
    // This test defines what messages the consumer expects to receive
    // Pact will generate a "contract" file from this test that can be shared with the provider
    public class ProductEventProcessorTests
    {
        // 1. The target of our test - our Product Event Handler
        //    This is the business logic that processes incoming product events
        private readonly ProductEventProcessor consumer;

        // 2. The Pact framework - this replaces Kafka in our tests
        //    It will generate messages and verify our handler can process them
        private readonly IMessagePactBuilderV4 pact;

        public ProductEventProcessorTests(ITestOutputHelper output)
        {
            consumer = new ProductEventProcessor();

            // 3. Setup Pact Message Consumer Constructor
            //    Configure the consumer and provider names, and where to save the contract
            var config = new PactConfig
            {
                PactDir = "../../../pacts/",  // Contract files will be saved here
                Outputters = new[]
                {
                    new XunitOutput(output)  // Show Pact output in test results
                }
            };

            // Create a message pact between our consumer and the provider
            // Consumer: "EventDrivenConsumer" (this application)
            // Provider: "EventDrivenProvider" (the system that sends us messages)
            pact = Pact.V4("EventDrivenConsumer", "EventDrivenProvider", config).WithMessageInteractions();
        }

        [Fact]
        public async Task ProductEventHandler_ProductCreated_HandlesMessage()
        {
            // 4. Arrange - Setup our message expectations
            //    We're telling Pact: "I expect to receive a product event update message"
            await pact
                      // The description of this interaction
                      // This will be used by the provider to map to their message generation function
                      .ExpectsToReceive("a product event update")
                      
                      // 5. Setup metadata - information about the message that isn't part of the content
                      //    In Kafka, this would include the topic name
                      //    For this test, we don't need to know HOW messages are sent, just what we expect
                      .WithMetadata("kafka_topic","products")
                      
                      // 6. The contents of the message we expect to receive
                      //    We use Pact matchers for flexible matching:
                      //    - Match.Type(): Accept any value of the same type as the example
                      //    - Match.Regex(): Accept values that match a regular expression
                      .WithJsonContent(new
                      {
                          id = Match.Type("some-uuid-1234-5678"),      // Any string is fine
                          type = Match.Type("Product Range"),           // Any string is fine
                          name = Match.Type("Some Product"),            // Any string is fine
                          version = Match.Type("v1"),                   // Any string is fine
                          @event = Match.Regex("UPDATED","^(CREATED|UPDATED|DELETED)$")  // Must be one of these three values
                      })
                      
                      // 7. Act & Assert - Verify our handler can process this message
                      //    Pact will:
                      //    - Create a message with the structure we defined
                      //    - Pass it to our ProductEventHandler
                      //    - If the handler completes successfully, the test passes
                      //    - If the handler throws an error, the test fails
                      //    - Generate a contract file in the pacts/ directory
                      .VerifyAsync<ProductEventProcessor.ProductEvent>(consumer.ProductEventHandler);
        }
    }
}