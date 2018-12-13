// packages:
// Microsoft.Extensions.Configuration.Binder
// Microsoft.Extensions.Configuration.Json
namespace Farfetch.RoutingService.Infrastructure.CrossCutting.Settings.Utils
{
    using System.IO;
    using Microsoft.Extensions.Configuration;

    /// <summary>
    /// Reads appsettings.json
    /// </summary>
    public static class SettingsReader
    {
        public static RoutingSettings GetSettings(string key = null,string outputPath = null) {
            var builder = new ConfigurationBuilder()
                .SetBasePath(outputPath ?? Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables();
            
            var routingSettings = new RoutingSettings();

            var configurationRoot = builder.Build();

            configurationRoot.GetSection(key ?? "RoutingSettings").Bind(routingSettings);

            return routingSettings;
        }
    }
}
