using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;

namespace Products.Controllers;

public class ProductsController : Controller
{
    private ProductRepository _repository;

    // This would usually be from a Repository/Data Store

    public ProductsController()
    {
        _repository = ProductRepository.GetInstance();
    }

    [HttpGet]
    [Route("/products")]
    public IActionResult GetAll()
    {
        return new JsonResult(_repository.GetProducts());
    }

    [HttpGet]
    [Route("/product/{id?}")]
    public IActionResult GetSingle(string id)
    {
        var product = _repository.GetProduct(id);
        if (product != null) 
        {
            return new JsonResult(product);
        }
        return new NotFoundResult();
    }

    /// <summary>
    /// API endpoint for the demo UI to retrieve all received events
    /// This shows what events the consumer has processed from Kafka
    /// </summary>
    [HttpGet]
    [Route("/api/events")]
    public IActionResult GetEvents()
    {
        // Return all products with timestamp for demo purposes
        var products = _repository.GetProducts();
        var events = products.Select(p => new
        {
            id = p.id,
            type = p.type,
            name = p.name,
            version = p.version,
            @event = "CREATED", // Simplified - in real system would track actual event type
            timestamp = DateTime.UtcNow.AddMinutes(-products.IndexOf(p)), // Demo timestamp
            processed = true,
            failed = false
        }).ToList();
        
        return new JsonResult(events);
    }
}
