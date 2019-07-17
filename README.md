# Swift Client Library for InfluxDB 2.0
Here’s a quick tutorial on how to use it.

```objc
    let influxdb = InfluxData()
```

That gets you an instance of the InfluxData class. Once you have that, you’ll need to set some configuration parameters for it.

```objc
    influxdb.setConfig(server: “serverName”, port: 9999, org: “myOrganization”, bucket: “myBucket”, token: “myToken”)
```

You will, of course, need to set all those values according to your InfluxDB v2.0 server’s settings. You can also set the time precision with

```objc
    let myPrecision = DataPrecision.ms // for Milliseconds, ‘us' for microseconds, and ’s’ for seconds
    influxdb.setPrecision(precision: myPrecision)
```

At this point, you’re ready to start collecting data and sending it to InfluxDB v2.0! For each data point you collect and want to store, you will create a new Influx object to hold the tags and data.

```objc
    let point: Influx = Influx(measurement: “myMeasurement")
    point.addTag(name: “location”, value: “home”)
    point.addTag(name: “server”, value: “home-server”)
    if !point.addValue(name: “value”, value: 100.01) {
        print(“Unknown value type!\n)
    }
    if !point.addValue(name: “value”, value: 55) {
        print(“Unknown value type!\n)
    }
    if !point.addValue(name: “value”, value: true) {
        print(“Unknown value type!\n)
    }
    if !point.addValue(name: “value”, value: “String Value" {
        print(“Unknown value type!\n)
    }
```

As you can see, it accepts Integers, floating point values, Booleans and strings. If it cannot determine the data type, it will return the Boolean false so it’s always a good idea to check the return value.

For best performance, we recommend writing data in batches to InfluxDB, so you’ll need to prepare the data to go into a batch. This is easy to do with a call to

```objc
    influxdb.prepare(point: point)
```

And when it’s time to write the batch, just call

```objc
    if influxdb.writeBatch() {
        print(“Batch written successfully!\n)
    }
```

Again, `writeBatch()` returns a Boolean on success or failure, so it’s a good idea to check those values.

If you want to write each data point as it comes in, just take the data point you created above and call

```objc 
    influxdb.writeSingle(dataPoint: point)
```

You can write data to multiple measurements simultaneously as each data point is initialized with its measurement, and you can add as many tags and fields as you’d like.

This is really the first pass at the InfluxDB v2.0 Swift library as I’ll be adding the ability to query, create buckets, and a lot of other features of the Flux language to the library in the future, but since what most people want to do right away is write data to the database, I thought I’d get this out there.