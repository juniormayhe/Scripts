namespace Converters
{
    using System.IO;
    using System.Threading.Tasks;

    public static class StreamConverter
    {
        /// <summary>
        /// Gets body stream from request or response.
        /// </summary>
        /// <param name="bodyStream">Tipically a HttpRequestStream / HttpResponseStream</param>
        /// <returns>Body as string content</returns>
        public static async Task<string> GetString(Stream bodyStream)
        {
            if (bodyStream == null || !bodyStream.CanRead)
            {
                return string.Empty;
            }

            bodyStream.Seek(0, SeekOrigin.Begin);

            return await new StreamReader(bodyStream).ReadToEndAsync();
        }
    }
}

namespace Infrastructure.CrossCutting.Tests.Converters
{
    using System.Diagnostics.CodeAnalysis;
    using System.IO;
    using System.Text;
    using System.Threading.Tasks;
    using Infrastructure.CrossCutting.Converters;
    using Xunit;

    [ExcludeFromCodeCoverage]

    public class StreamConverterTests
    {
        [Fact]
        public async Task GetString_WithNullStream_ReturnsEmpty()
        {
            string result = await StreamConverter.GetString(null);
            Assert.Empty(result);
        }

        [Fact]
        public async Task GetString_WithEmptyStream_ReturnsEmpty()
        {
            string result = await StreamConverter.GetString(new MemoryStream());
            Assert.Empty(result);
        }

        [Fact]
        public async Task GetString_WithClosedStream_ReturnsEmpty()
        {
            MemoryStream bodyStream = new MemoryStream();
            bodyStream.Close();

            string result = await StreamConverter.GetString(bodyStream);
            Assert.Empty(result);
        }

        [Fact]
        public async Task GetString_WithStream_ReturnsString()
        {
            string expectedBody = "{{ \"salute\": \"hello ff\" }}";
            Stream bodyStream = new MemoryStream(Encoding.UTF8.GetBytes(expectedBody));

            string result = await StreamConverter.GetString(bodyStream);

            Assert.NotEmpty(result);
            Assert.Equal(expectedBody, result);
        }
    }
}
