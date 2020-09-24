```csharp        
IHttpClientBuilder httpClientBuilder = services.AddHttpClient(settings.Name, client =>  { client.BaseAddress = new Uri("http://endpoint"); });

#if DEBUG
// ignore self signed certificates errors that cannot be validated
httpClientBuilder.ConfigureHttpMessageHandlerBuilder(builder =>
{
  builder.PrimaryHandler = new HttpClientHandler
  {
    ServerCertificateCustomValidationCallback = (m, c, ch, e) => true
  };
});
#endif
```

Avoids this error:
```json
"Exception":{
   "Message":"The SSL connection could not be established, see inner exception.",
   "Data":{

   },
   "InnerException":{
      "ClassName":"System.Security.Authentication.AuthenticationException",
      "Message":"The remote certificate is invalid according to the validation procedure.",
      "Data":null,
      "InnerException":null,
      "HelpURL":null,
      "StackTraceString":"   at System.Net.Security.SslState.StartSendAuthResetSignal(ProtocolToken message, AsyncProtocolRequest asyncRequest, ExceptionDispatchInfo exception)\r\n   at System.Net.Security.SslState.CheckCompletionBeforeNextReceive(ProtocolToken message, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartSendBlob(Byte[] incoming, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.ProcessReceivedBlob(Byte[] buffer, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartReadFrame(Byte[] buffer, Int32 readBytes, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartReceiveBlob(Byte[] buffer, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.CheckCompletionBeforeNextReceive(ProtocolToken message, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartSendBlob(Byte[] incoming, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.ProcessReceivedBlob(Byte[] buffer, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartReadFrame(Byte[] buffer, Int32 readBytes, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartReceiveBlob(Byte[] buffer, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.CheckCompletionBeforeNextReceive(ProtocolToken message, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartSendBlob(Byte[] incoming, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.ProcessReceivedBlob(Byte[] buffer, Int32 count, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.StartReadFrame(Byte[] buffer, Int32 readBytes, AsyncProtocolRequest asyncRequest)\r\n   at System.Net.Security.SslState.PartialFrameCallback(AsyncProtocolRequest asyncRequest)\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Net.Security.SslState.ThrowIfExceptional()\r\n   at System.Net.Security.SslState.InternalEndProcessAuthentication(LazyAsyncResult lazyResult)\r\n   at System.Net.Security.SslState.EndProcessAuthentication(IAsyncResult result)\r\n   at System.Net.Security.SslStream.EndAuthenticateAsClient(IAsyncResult asyncResult)\r\n   at System.Net.Security.SslStream.<>c.<AuthenticateAsClientAsync>b__47_1(IAsyncResult iar)\r\n   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Net.Http.ConnectHelper.EstablishSslConnectionAsyncCore(Stream stream, SslClientAuthenticationOptions sslOptions, CancellationToken cancellationToken)",
      "RemoteStackTraceString":null,
      "RemoteStackIndex":0,
      "ExceptionMethod":null,
      "HResult":-2146233087,
      "Source":"System.Private.CoreLib",
      "WatsonBuckets":null
   },
   "StackTrace":"   at System.Net.Http.ConnectHelper.EstablishSslConnectionAsyncCore(Stream stream, SslClientAuthenticationOptions sslOptions, CancellationToken cancellationToken)\r\n   at System.Threading.Tasks.ValueTask`1.get_Result()\r\n   at System.Net.Http.HttpConnectionPool.CreateConnectionAsync(HttpRequestMessage request, CancellationToken cancellationToken)\r\n   at System.Threading.Tasks.ValueTask`1.get_Result()\r\n   at System.Net.Http.HttpConnectionPool.WaitForCreatedConnectionAsync(ValueTask`1 creationTask)\r\n   at System.Threading.Tasks.ValueTask`1.get_Result()\r\n   at System.Net.Http.HttpConnectionPool.SendWithRetryAsync(HttpRequestMessage request, Boolean doRequestAuth, CancellationToken cancellationToken)\r\n   at System.Net.Http.RedirectHandler.SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)\r\n   at System.Net.Http.DiagnosticsHandler.SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)\r\n   ..."
   "HelpLink":null,
   "Source":"System.Net.Http",
   "HResult":-2146233087
}
```
