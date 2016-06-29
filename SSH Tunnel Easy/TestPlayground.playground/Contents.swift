//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

NSFileManager().URLsForDirectory(.DocumentationDirectory, inDomains: .UserDomainMask)
NSFileManager().currentDirectoryPath
NSFileManager().URLsForDirectory(.UserDirectory, inDomains: .UserDomainMask)

let pref = NSUserDefaults()
let name = "TopCaver"
pref.setObject(name, forKey: "name")
pref.stringForKey("name")

class TestClass : NSObject, NSCoding {
    var test_name = "defalut_name"
    func foo()->String{
        return test_name
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(test_name, forKey: "test_name")
    }
    override init(){
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        let test_name = aDecoder.decodeObjectForKey("test_name") as! String
        self.test_name = test_name
    }
}

let tc = TestClass()
tc.foo()
tc.test_name = "topcaver"

class TD : NSDictionary{
    var a = "a"
}

let tdata = NSKeyedArchiver.archivedDataWithRootObject(tc)
pref.setObject(tdata, forKey: "tdata")
let tdata_2 = NSKeyedUnarchiver.unarchiveObjectWithData(pref.dataForKey("tdata")!) as! TestClass
tdata_2.foo()

//pref.setObject(NSData(NSArchiver.archivedDataWithRootObject(tc)), forKey: "tc")
let pipe = NSPipe()
let pipe2 = NSPipe()
//let task = NSTask.launchedTaskWithLaunchPath("/usr/bin/ssh", arguments: ["topcaver@topcaver.com","&"])
let task2 = NSTask()
task2.launchPath = "/bin/cat"
task2.standardOutput = pipe
task2.standardInput = pipe2
task2.launch()

let stdin = pipe2.fileHandleForWriting
stdin.writeData("hello".dataUsingEncoding(NSUTF8StringEncoding)!)
stdin.closeFile()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
print("a")
print(NSString(data: data, encoding: NSUTF8StringEncoding))

var bundle = NSBundle.mainBundle()
bundle.pathForResource("Info", ofType: "plist")


//print(task.processIdentifier)
//task.waitUntilExit()
//print("?")
//print(task.terminationStatus)


