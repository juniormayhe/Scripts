# Hangfire

## mock PerformContext for testing

To inject performContext we can use

```csharp
namespace YourTestProject
{
    using System;

    using Hangfire;
    using Hangfire.Server;
    using Hangfire.Storage;

    using Moq;

    internal class PerformContextMock
    {
        private readonly Lazy<PerformContext> context;
        private readonly Mock<JobStorage> jobStorage;

        public PerformContextMock()
        {
            this.Connection = new Mock<IStorageConnection>();
            this.BackgroundJob = new BackgroundJobMock();
            this.CancellationToken = new Mock<IJobCancellationToken>();
            this.jobStorage = new Mock<JobStorage>();

            this.context = new Lazy<PerformContext>(
                () => new PerformContext(this.jobStorage.Object, this.Connection.Object, this.BackgroundJob.Object, this.CancellationToken.Object));
        }

        public Mock<IStorageConnection> Connection { get; set; }

        public BackgroundJobMock BackgroundJob { get; set; }

        public Mock<IJobCancellationToken> CancellationToken { get; set; }

        public PerformContext Object => this.context.Value;

        public static void SomeMethod()
        {
        }
    }
}

namespace MyTestProject
{
    using System;

    using Hangfire;
    using Hangfire.Common;

    public class BackgroundJobMock
    {
        private readonly Lazy<BackgroundJob> @object;

        public BackgroundJobMock()
        {
            this.Id = "JobId";
            this.Job = Job.FromExpression(() => SomeMethod());
            this.CreatedAt = DateTime.UtcNow;

            this.@object = new Lazy<BackgroundJob>(
                () => new BackgroundJob(this.Id, this.Job, this.CreatedAt));
        }

        public string Id { get; set; }

        public Job Job { get; set; }

        public DateTime CreatedAt { get; set; }

        public BackgroundJob Object => this.@object.Value;

        public static void SomeMethod()
        {
        }
    }
}
```

In test method:
```csharp
[Fact]
public async Task RecurrentJob_Completed()
{
    // Arrange
    ..
    // Act
    var job = new YourRecurrentJob(this.jobClient);
    await job.ExecuteAsync(context: new PerformContextMock().Object);
```

## A recurrent job
```
namespace YourJobs
{
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Threading.Tasks;

    using global::Hangfire;
    using global::Hangfire.Console;
    using global::Hangfire.Dashboard.Management.Metadata;
    using global::Hangfire.Dashboard.Management.Support;
    using global::Hangfire.Server;

    [ManagementPage("Your recurrent job page name", "default")]
    public class YourRecurrentJob
    {
        private readonly IBackgroundJobClient client;

        public YourRecurrentJob(IBackgroundJobClient client)
        {
            this.client = client;
        }

        [Job]
        [RetentionTimeAttribute(timeInHours: 72)]
        [DisableConcurrentExecution(1)]
        [AutomaticRetry(Attempts = 0, LogEvents = false, OnAttemptsExceeded = AttemptsExceededAction.Fail)]
        [DisplayName("Recreate all Merchant Entries")]
        [Description("Recreates merchant entries both in mongo db and in cassandra.")]
        public async Task ExecuteAsync(
            PerformContext context,
            [DisplayData("Your label for input parameter", "Your placeholder text", "Your long description for the input field")] DateTime orderDate)
        {
            this.context = context;
            var progress = context.WriteProgressBar();

            // inject other classes to do stuff;

            context.WriteLine(ConsoleTextColor.Green, "Result: Completed Normally");
            
            // set progress
            this.progress.SetValue(this.progressPercentage);
        }
    }
}

```

## Add hangfire to startup

```csharp
namespace MyWebAPI
{
    using System;

    using Microsoft.AspNetCore.Builder;
    using Microsoft.AspNetCore.Hosting;
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.Extensions.Hosting;

    [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
    public partial class Startup
    {
        public Startup(IConfiguration configuration)
        {
            this.Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services
                ...
                .AddYourJobs(this.Configuration);
        }

        public void Configure(IApplicationBuilder appBuilder, IServiceProvider serviceProvider, IWebHostEnvironment hostEnvironment, IHostApplicationLifetime appLifetime)
        {
            appBuilder
                ...
                .UseYourJobs();

            appLifetime.ConfigureMessagingServicesLifetime(serviceProvider);
        }

        public static IServiceCollection AddOuterJobsServices(this IServiceCollection services, IConfiguration configuration)
        {
            var hangfireSettings = services.AddAndGetSettings<HangfireSettings>(configuration);
            
            services
               ...
               .AddHangfire((serviceProvider, config) =>
               {
                    config.UseMongoStorage(settings.MongoSettings.ConnectionString, new MongoStorageOptions
                    {
                        MigrationOptions = new MongoMigrationOptions(settings.MongoSettings.MigrationStrategy)
                    });

                    config
                        .UseColouredConsoleLogProvider()
                        .UseSimpleAssemblyNameTypeSerializer()
                        .UseRecommendedSerializerSettings()
                        .UseConsole()
                        .UseDashboardMetric(DashboardMetrics.ServerCount)
                        .UseDashboardMetric(DashboardMetrics.RecurringJobCount)
                        .UseDashboardMetric(DashboardMetrics.RetriesCount)
                        .UseDashboardMetric(DashboardMetrics.EnqueuedAndQueueCount)
                        .UseDashboardMetric(DashboardMetrics.ScheduledCount)
                        .UseDashboardMetric(DashboardMetrics.ProcessingCount)
                        .UseDashboardMetric(DashboardMetrics.SucceededCount)
                        .UseDashboardMetric(DashboardMetrics.FailedCount)
                        .UseManagementPages(options =>
                        {
                            return options
                                .AddJobs(Assembly.GetExecutingAssembly());
                        });
               });

            services.AddHangfireServer(options => options.Queues = new[] { Environment.MachineName });
            
            return services;
        }

        public static IApplicationBuilder UseYourJobs(this IApplicationBuilder appBuilder)
        {
            var hangfireSettings = appBuilder.ApplicationServices.GetRequiredService<IOptions<HangfireSettings>>().Value;

            if (hangfireSettings.Enabled)
            {
                var dashboardOptions = new DashboardOptions
                {
                    Authorization = new[] { new PassthroughDashboardAuthorization() },
                    DashboardTitle = "My Hangfire dashboard title",
                    DisplayStorageConnectionString = false,
                    DisplayNameFunc = (ctx, job) => job.Type.Name
                };

                appBuilder.UseHangfireDashboard("/hangfire", dashboardOptions);
                appBuilder.UseHangfireServer();
            }

            return appBuilder;
        }
    }
}

```
## Settings
```json
{
  "SystemLogging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "*",

  "HangfireSettings": {
    "Enabled": true,
    "MongoSettings": {
      "ConnectionString": "mongodb://localhost:27017/your_db_name",
      "MigrationStrategy": "Migrate"
    }
  }
}
```
