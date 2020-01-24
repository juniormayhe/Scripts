namespace Infrastructure.CrossCutting.Converters
{
    using Utf8Json;

    /// <summary>
    /// Fast serializer
    /// </summary>
    public static class Utf8JsonSerializer
    {
        public static T Deserialize<T>(string input)
            where T : class
        {
            T @type = JsonSerializer.Deserialize<T>(input);

            return @type;
        }

        public static string Serialize<T>(T @object)
            where T : class
        {
            return JsonSerializer.ToJsonString(@object);
        }
    }
}
