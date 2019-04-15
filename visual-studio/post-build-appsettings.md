In a project test, if release mode then copies Settings\appsettings.jenkins.json to .\netstandard2.0\Settings\appsettings.Release.json

```
mkdir "$(TargetDir)\Settings\"
if "$(Configuration)" == "Release" (
  copy "$(ProjectDir)Settings\appsettings.jenkins.json" "$(TargetDir)Settings\appsettings.Release.json" /y
) else (
  copy "$(ProjectDir)Settings\appsettings.json" "$(TargetDir)Settings\appsettings.Release.json" /y
)
```

grab the Settings
```
    public class Settings
    {
        public static string GetSettings(string section)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Path.Combine(Directory.GetCurrentDirectory(), "Settings"))
                // a post build command copies appsettings.json as appsettings.Release.json for Debug mode
                // or the template file appsettings.jenkins.json as appsettings.Release.json for Release mode
                .AddJsonFile("appsettings.Release.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            return config.GetSection(section).Value;
        }
    }
    
    public static YourHelperClass(){ public static string GetApiURL { return Settings.GetSettings("ApiURL"); } }
```

