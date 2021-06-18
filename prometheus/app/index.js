// install express
// npm install --save express
var express = require('express');
var app = express();


// install prometheus client 
// npm install --save prom-client
var client = require('prom-client');

const requestsCounter = new client.Counter({
    name: 'myapp_requests_counter',
    help: 'Requests counter',
    labelNames: ['statusCode']
});

const onlineUserGauge = new client.Gauge({
    name: 'myapp_online_users_total',
    help: 'Online users total'
});

const responseDurationHistogram = new client.Histogram({
    name: 'myapp_request_duration_seconds',
    help: 'Request duration in seconds',
    //buckets: [0.1, 0.2, 0.3, 0.4, 0.5] -> we use instead promclient default buckets
});

const summary = new client.Summary({
    name: 'myapp_summary_response_time',
    help: 'myapp_Summary response time in seconds',
    percentiles: [0.5, 0.9, 0.99]
});

const register = client.register;

var resetUsers = false;

function randn_bm(min, max, skew) {
    let u = 0, v = 0;
    while(u === 0) u = Math.random() //Converting [0,1) to (0,1)
    while(v === 0) v = Math.random()
    let num = Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v )
    
    num = num / 10.0 + 0.5 // Translate to 0 -> 1
    if (num > 1 || num < 0) 
      num = randn_bm(min, max, skew) // resample between 0 and 1 if out of range
    
    else{
      num = Math.pow(num, skew) // Skew
      num *= max - min // Stretch to fill range
      num += min // offset to min
    }
    return num
  }

setInterval(()=> {
    // increment requests counter
    var errorChancePercentage = 5;
    var randomStatusCode = (Math.random() < errorChancePercentage / 100) ? '500' : '200';
    requestsCounter.labels(randomStatusCode).inc();
    
    // update online users gauge
    const maxAdditionalUsers = 50;
    let randomUsers = 500 + Math.round(Math.random() * maxAdditionalUsers); // maximum is 550 users
    let onlineUsers = resetUsers ? 0 : randomUsers;

    onlineUserGauge.set(onlineUsers);

    // observe response duration
    const randomDuration = randn_bm(0, 3, 4);
    responseDurationHistogram.observe(randomDuration);
    summary.observe(randomDuration);

},100);

app.get('/', function (req, res) {
    res.send('hello');
});

app.get('/reset-users', function (req, res) {
    resetUsers = true;
    res.send('We will reset users');
});

app.get('/return-users', function (req, res) {
    resetUsers = false;
    res.send('We will NOT reset users');
});

app.get('/metrics', async function (req, res) {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());

});
app.listen(3030);
