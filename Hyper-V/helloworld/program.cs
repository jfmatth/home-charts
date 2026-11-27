var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var startupTime = DateTime.Now;
var processId = Environment.ProcessId;

app.MapGet("/", () => $@"
<html>
<head>
    <title>Hello World Test</title>
</head>
<body>
    <h1>Hello World</h1>
    <p>Application Startup Time: {startupTime:yyyy-MM-dd HH:mm:ss}</p>
    <p>Process ID: {processId}</p>
    <p>Current Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}</p>
</body>
</html>");

app.Run();