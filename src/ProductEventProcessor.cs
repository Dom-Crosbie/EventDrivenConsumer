using System;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Products
{
    // CONSUMER: This is the "Port" in the Ports and Adapters architecture
    // It handles the business logic (domain) without knowing about Kafka or any messaging technology
    // In a real application, an "Adapter" (like a Kafka consumer) would receive messages
    // and pass them to this handler
    public class ProductEventProcessor
    {
        private readonly ProductRepository _repository;

        public ProductEventProcessor()
        {
            _repository = ProductRepository.GetInstance();
        }

        // ProductEvent represents the message structure we expect to receive
        // It extends Product and adds an "event" field to indicate what happened
        public class ProductEvent(string id, string type, string name, string version, string @event) : Product(id, type, name, version)
        {
            [JsonPropertyName("event")]
            public string Event { get; set; } = @event;
        }

        // This is the TARGET of our Pact test - the function that processes product events
        // It's isolated from the messaging infrastructure, which makes it easy to test
        // In production: Kafka message -> Adapter (deserializes) -> This handler
        // In Pact test: Pact framework -> This handler directly
        public Task ProductEventHandler(ProductEvent productEvent)
        {
            Console.WriteLine($"Received product: {productEvent}");
            Console.WriteLine($"Received product event: {productEvent.Event}");
            Console.WriteLine($"Received product id: {productEvent.id}");

            // Handle different event types
            if (productEvent.Event == "CREATED" || productEvent.Event == "UPDATED")
            {
                _repository.AddProduct(new Product(productEvent.id,productEvent.type,productEvent.name,productEvent.version));
            }
            else if (productEvent.Event == "DELETED")
            {
                _repository.RemoveProduct(productEvent.id);
            }
            else
            {
                // If we can't handle the event, throw an error
                // This will cause the Pact test to fail if the contract doesn't match our expectations
                throw new InvalidOperationException("Unable to process event");
            }

            return Task.CompletedTask;
        }
    }
}