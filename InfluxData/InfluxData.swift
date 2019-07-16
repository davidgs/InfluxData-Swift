//
//  Created by David G. Simmons on 2/21/19.
//  Copyright © 2019 David G. Simmons. All rights reserved.
//

#if os(macOS)
import Cocoa
#elseif os(Linux)
import Foundation
public typealias uint16 = UInt16
#endif

/*
 *
 */
public class InfluxData {
    // Write endpoint for InfluxDB v2.0
    let _urlString: String = "/api/v2/write?org="
    // transmission protocol.
    var _proto: String = "http"
    // server address
    var _server: String = ""
    // server port
    var _port: uint16 = 9999
    // Influx Organization
    var _org: String = ""
    // Data Bucket
    var _bucket: String = ""
    // Authorization Token
    var _token: String = ""
    // timestamp precision
    var _precision: DataPrecision = DataPrecision.us
    // batch of datapoints for batch processing
    var _multiPoint:[Influx] = []
    
    var retMess: String = ""
    
    // create an instance.
    public init(){
        
    }
    /**
     * Configure an influxDB instance with all required values
     * @param server InfluxDB v2 server to use
     * @param port Server port
     * @param org Influxdb Organization to use -- MUST already exist!
     * @param bucket Data bucket to use -- MUST already exist!
     * @param token InfluxDB Token
     */
    public func setConfig(server: String, port: uint16, org: String, bucket: String, token: String) {
        self._server = server
        self._port = port
        self._org = org
        self._bucket = bucket
        self._token = token
        
    }
    
    /**
     * Add a data point to a batch to be written later.
     * @param point an Influx data Point to add to a batch
     */
    public func prepare(point: Influx){
        self._multiPoint.append(point)
    }
    
    /**
     *
     * @param server Set the server address
     */
    public func setServer(server: String){
        self._server = server
    }
    
    /*
     * @param port Set server port. default is 9999
     */
    public func setPort(port: uint16){
        self._port = port
    }
    
    /**
     * @param org Set the InfluxDB Organization to use -- MUST already aexist!
     */
    public func setOrg(org: String){
        self._org = org
    }
    
    /**
     * @param bucket Set the data bucket to use -- MUST already exist
     */
    public func setBucket(bucket: String){
        self._bucket = bucket
    }
    
    /**
     * @param token Set the access token: This is required!
     */
    public func setToken(token: String){
        self._token = token
    }
    /**
     * @param proto Set the protocol to either http or https. Default is http
     **/
    public func setProto(proto: String) -> Bool{
        if(proto != "http" && proto != "https"){
            return false
        }
        self._proto = proto
        return true
    }
    
    /**
     * @param precision set the timestamp precision to use
     */
    public func setPrecision(precision: DataPrecision){
        self._precision = precision
    }
    
    /**
     * Return the fully formed URL as a string including all options.
     */
    public func getConfig() -> String{
        if(_port > 0){
            return "\(_proto)://\(_server):\(_port)\(_urlString)\(_org)&bucket=\(_bucket)&precision=\(_precision)"
        }
        else {
            return "\(_proto)://\(_server)\(_urlString)\(_org)&bucket=\(_bucket)&precision=\(_precision)"
        }
    }
    
    /**
     * Write the batch of prepared data points to the database.
     */
    public func writeBatch() -> Bool{
        if self._multiPoint.count < 1 {
            return false
        }
        var points = ""
        for data in _multiPoint {
            points = "\(points)\(data.toString()) \(getTimeStamp())\n"
        }
        points.removeLast()
        _multiPoint.removeAll()
        let postUrl = URL(string: self.getConfig())
        var request = URLRequest(url: postUrl!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self._token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = points.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    DispatchQueue.main.async {
                        print("Error: ", error ?? "Unknown error")
                        self.retMess = "Error: \(String(describing: error)) Unknown error"
                    }
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                DispatchQueue.main.async {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    self.retMess = "statusCode should be 2xx, but is \(response.statusCode)"
                    print("response = \(response.statusCode)")
                }
                return
            }
            DispatchQueue.main.async {
                self.retMess = "InfluxDB response: \(response.statusCode)"
                print("InfluxDB response: \(response.statusCode)")
            }
            
        }
        task.resume()
        return true
    }
    
    /**
     * @param Single Influx Datapoint to write to the db
     */
    public func writeSingle(dataPoint: Influx){
        let postUrl = URL(string: self.getConfig())
        var request = URLRequest(url: postUrl!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self._token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "\(dataPoint.toString()) \(getTimeStamp())".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    DispatchQueue.main.async {
                        print("Error:  \(String(describing: error)) Unknown error")
                        self.retMess = "Error:  \(String(describing: error)) Unknown error"
                    }
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                DispatchQueue.main.async {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    self.retMess = "statusCode should be 2xx, but is \(response.statusCode)"
                    print("response = \(response.statusCode)")
                }
                return
            }
            DispatchQueue.main.async {
                self.retMess = "InfluxDB response: \(response.statusCode)"
                print("InfluxDB response: \(response.statusCode)")
            }
            
        }
        task.resume()
    }
    
    // construct the timestamp based on the configured precision.
    // only supporting seconds, milliseconds and microseconds now
    func getTimeStamp() -> String {
        var time = timeval()
        gettimeofday(&time, nil)
        switch _precision {
        case DataPrecision.s:
            return "\(time.tv_sec)"
        case DataPrecision.us:
            return "\(time.tv_sec)\(time.tv_usec)"
        default:
            var ms = "\(time.tv_sec)\(time.tv_usec)"
            ms.removeLast()
            ms.removeLast()
            ms.removeLast()
            return ms
            
        }
    }
}

/*
 * Influx data point object.
 */
public class Influx {
    // measurement to insert into
    var _measurement: String = ""
    // tags
    var _tag: [String:String] = [:]
    // values
    var _value: [String:Any] = [:]
    
    /*
     * Create a new data point for a given measurement
     * @param measurement to store into
     */
    public init(measurement: String){
        self._measurement = measurement
    }
    
    /*
     * Add a tag to a data point
     * @param name Name of the tag
     * @param value Tag value
     */
    public func addTag(name: String, value: String){
        self._tag[name] = value
    }
    
    /*
     * Add a value to the point
     * @param name value name
     * @param value value to be added can be Int, Float, Bool or String
     * @return boolean true if accepted daa, false otherwise
     */
    public func addValue(name: String, value: Any) -> Bool{
        
        switch value {
        case is Int:
            self._value.updateValue(value, forKey: name)
            return true
        case is Float:
            self._value.updateValue(value, forKey: name)
            return true
        case is Bool:
            self._value.updateValue(value as! Bool, forKey: name)
            return true
        case is String:
            self._value.updateValue(value as! String, forKey: name)
            return true
        default:
            print("Not a supported value type!\n")
            return false
        }
        //return false
    }
    
    /*
     * Get the point's tags as a key=value string
     * @return string of comma-separataed key=value pairs
     */
    public func getTags() -> String {
        var tagString = ""
        for (key, value) in self._tag {
            let ts = "\(tagString)\(key)=\(value)"
            tagString = "\(ts),"
        }
        tagString.removeLast()
        return tagString
    }
    
    /*
     * Get the point's data values
     * @return comma-separated key=value pairs
     */
    public func getValues() -> String {
        var valString = " "
        for (key, value) in self._value {
            valString = "\(valString)\(key)=\(value),"
        }
        valString.removeLast()
        return valString
    }
    
    /*
     * return the data point as a Line Protocol formatted string.
     */
    public func toString() -> String {
        let s = "\(_measurement),\(getTags())\(getValues())"
        return s
    }
    
    
}

/*
 * Data Precision formats
 */
public enum DataPrecision {
    case s, ms, us
}
