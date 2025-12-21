#:sdk Microsoft.NET.Sdk.Web

using Microsoft.Extensions.FileProviders;
var argsList = args ?? Array.Empty<string>();

// 1. 解析根目录参数
string rootArg = argsList.Length > 0 && !string.IsNullOrWhiteSpace(argsList[0])
    ? argsList[0]
    : string.Empty;

string baseDir = Directory.GetCurrentDirectory();
string defaultWebRoot = Path.Combine(baseDir, "WebSite");

string root = !string.IsNullOrEmpty(rootArg)
    ? rootArg
    : (Directory.Exists(defaultWebRoot) ? defaultWebRoot : baseDir);

if (!Path.IsPathRooted(root))
{
    root = Path.GetFullPath(Path.Combine(baseDir, root));
}

int port = 5200;
if (argsList.Length > 1 && int.TryParse(argsList[1], out var p) && p > 0 && p <= 65535)
{
    port = p;
}
var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = root,
    WebRootPath = root
});

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenLocalhost(port);
});
var app = builder.Build();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(root),
    RequestPath = "",
});
app.MapFallbackToFile("index.html");

await app.RunAsync();
