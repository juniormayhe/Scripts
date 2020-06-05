    using System;
    using System.Threading;
    using System.Threading.Tasks;

    using Polly;

    internal class TaskThrottling : System.IDisposable
    {
        private readonly Semaphore semaphore;
        private static readonly Random Jitterer = new Random();

        public TaskThrottling()
        {
            // useful to limits database tasks for example, if mongo supports max of 100
            this.semaphore = new Semaphore(initialCount: 50, maximumCount: 50);
        }

        public async Task AddAsync(Task task)
        {
            this.semaphore.WaitOne();

            try
            {
                await Policy
                  .Handle<Exception>()
                  .WaitAndRetryAsync(
                      retryCount: 5,
                      sleepDurationProvider: (retryAttempt) =>
                      {
                          // exponential back-off: 2, 4, 8 etc
                          TimeSpan exponentialBackoff = TimeSpan.FromSeconds(Math.Pow(2, retryAttempt));

                          // plus some jitter: up to 1 second
                          TimeSpan jitter = TimeSpan.FromMilliseconds(Jitterer.Next(0, 1000));

                          return exponentialBackoff + jitter;
                      },
                      onRetry: (exception, waitTime, retryCount, _) =>
                      {
                          Console.WriteLine($"Request failed with {exception.Message}. Waiting {waitTime} before next retry. Retry attempt {retryCount}");
                      })
                  .ExecuteAsync(() => task);
            }
            finally
            {
                this.semaphore.Release();
            }
        }

        public void Dispose()
        {
            this.semaphore.Dispose();
        }
    }
