#:sdk Microsoft.NET.Sdk.Web
var baseDir = Directory.GetCurrentDirectory();
var root = args.Length > 0 && !string.IsNullOrWhiteSpace(args[0])
    ? Path.GetFullPath(args[0])
    : Path.Combine(baseDir, "WebSite");
var port = args.Length > 1 && int.TryParse(args[1], out var p) ? p : 5200;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    WebRootPath = root
});

builder.WebHost.UseUrls($"http://localhost:{port}");
var app = builder.Build();
app.UseFileServer();
await app.RunAsync();