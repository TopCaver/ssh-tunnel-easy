//
//  SshTunnel.swift
//  SSH Tunnel Easy
//
//  Created by TopCaver on 16/4/22.
//  Copyright © 2016年 TopCaver. All rights reserved.
//

import Cocoa

class SshTunnel: NSObject, NSCoding{
    
    var name: String
    var localPort: String?
    var host: String?
    var port: String?
    var username: String?
    var password: String?
    
    struct sshTunnelEncodeKey {
        static let name = "name"
        static let localPort = "localPort"
        static let host = "host"
        static let port = "port"
        static let username = "username"
        static let password = "password"
    }
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentationDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("sshtunnels")
    
    init?(_ name:String, host:String?=nil, port:String?=nil, localPort:String?=nil, username:String?=nil, password:String?=nil) {
        // TODO
        self.name = name
        self.host = host
        self.port = port
        self.localPort = localPort
        self.username = username
        self.password = password
        
        super.init()
        
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: Connect
    func commandLineString() -> (String,[String])? {
        // generate ssh command line
        if self.host != nil && self.port != nil && self.username != nil {
            //            var commandLine = "ssh -N -p 22 -c 3des -D 7070 cys_947d0d20@s4.cyssh.com"
            let commandPath = "/usr/bin/ssh"
            var commandArgs = ["-p \(self.port!)"]
            if self.localPort != nil {
                commandArgs.append("-D \(self.localPort!)")
            }
            commandArgs.append("\(self.username!)@\(self.host!)")
            
//            var commandLine = "ssh -N -p"
            return (commandPath,commandArgs)
        }
        return nil
    }
    
    func connect(){
        if self.host != nil && self.port != nil && self.username != nil {
            // var commandLine = "ssh -N -p 22 -c 3des -D 7070 cys_947d0d20@s4.cyssh.com"
            let commandPath = "/usr/bin/expect"
            let bundle = NSBundle.mainBundle()
//            print(bundle.bundlePath)
            print(bundle.pathForResource("expect-ssh-topcaver", ofType: "exp"))
//            let commandPath = "/bin/pwd"
            var commandArgs = ["-f", bundle.pathForResource("expect-ssh-topcaver", ofType: "exp")!]
            commandArgs.append("\(self.host!)")
            commandArgs.append("\(self.port!)")
            commandArgs.append("\(self.username!)")
            commandArgs.append("\(self.password!)")
            commandArgs.append("\(self.localPort!)")
            
            let stdout = NSPipe()
            
            let task = NSTask()
            task.launchPath = commandPath
            task.arguments = commandArgs
            print("\(commandPath):\(commandArgs)")
            task.standardOutput = stdout
            task.standardError = stdout
            
            task.launch()
            print(task.processIdentifier)
//            let outData = stdout.fileHandleForReading.readDataToEndOfFile()
//            print(NSString(data: outData, encoding: NSUTF8StringEncoding) )
            
//            task.waitUntilExit()
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        // coding the sshtunnel
        aCoder.encodeObject(name,forKey: sshTunnelEncodeKey.name)
        aCoder.encodeObject(host, forKey: sshTunnelEncodeKey.host)
        aCoder.encodeObject(port, forKey: sshTunnelEncodeKey.port)
        aCoder.encodeObject(localPort, forKey: sshTunnelEncodeKey.localPort)
        aCoder.encodeObject(username, forKey: sshTunnelEncodeKey.username)
        aCoder.encodeObject(password, forKey: sshTunnelEncodeKey.password)
    }
        
    required convenience init?(coder aDecoder: NSCoder) {
        // encodig from stored
        let name = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.name) as! String
        let host = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.host) as? String
        let port = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.port) as? String
        let localPort = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.localPort) as? String
        let username = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.username) as? String
        let password = aDecoder.decodeObjectForKey(sshTunnelEncodeKey.password) as? String
        self.init(name,host:host,port:port,localPort: localPort, username: username, password: password)
    }
}
