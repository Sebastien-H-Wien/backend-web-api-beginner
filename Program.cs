using BackendAPI.User.Data;
using NSwag;
using NSwag.Generation.Processors.Security;


var builder = WebApplication.CreateBuilder(args);





builder.AddApplicationServices();

var conString =  builder.Configuration["ApplicationDbContext"] ??
     throw new InvalidOperationException("Connection string 'ApplicationDbContext' not found.");

await using var conn = new NpgsqlConnection(conString);
await using var dataSource = NpgsqlDataSource.Create(conString);

await conn.OpenAsync();
IHostEnvironment env = builder.Environment;

// builder.Services.AddDatabaseDeveloperPageExceptionFilter();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();


builder.Services.AddOpenApiDocument((configure, sp) =>
        {
            configure.Title = "webapp_backend_dotnet API";

            // Add JWT
            configure.AddSecurity("JWT", Enumerable.Empty<string>(), new OpenApiSecurityScheme
            {
                Type = OpenApiSecuritySchemeType.ApiKey,
                Name = "Authorization",
                In = OpenApiSecurityApiKeyLocation.Header,
                Description = "Type into the textbox: Bearer {your JWT token}."
            });

            configure.OperationProcessors.Add(new AspNetCoreOperationSecurityScopeProcessor("JWT"));
        });

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseOpenApi(p => p.Path = "/swagger/{documentName}/swagger.yaml"); // https://github.com/RicoSuter/NSwag/wiki/AspNetCore-Middleware#generate-specification-in-yaml-format
    app.UseSwaggerUi(config =>
    {
        config.DocumentTitle = "User API";
        config.Path = "/swagger";
        // config.DocumentPath = "/swagger/{documentName}/swagger.json";
        config.DocumentPath = "/swagger/{documentName}/swagger.yaml"; // https://github.com/RicoSuter/NSwag/wiki/AspNetCore-Middleware#generate-specification-in-yaml-format
        config.DocExpansion = "list";
    });
}





// Exception handler
app.UseExceptionHandler(exceptionHandlerApp =>
{
    exceptionHandlerApp.Run(async httpContext =>
    {
        var pds = httpContext.RequestServices.GetService<IProblemDetailsService>();
        if (pds == null
            || !await pds.TryWriteAsync(new() { HttpContext = httpContext }))
        {
            // Fallback behavior
            await httpContext.Response.WriteAsync("Fallback: An error occurred.");
        }
    });
});
app.UseStatusCodePages(async statusCodeContext => await Results
                                                        .Problem(statusCode: statusCodeContext.HttpContext.Response.StatusCode)
                                                        .ExecuteAsync(statusCodeContext.HttpContext));





app.MapGet("/", () => "Hello World!");

app.Run();
