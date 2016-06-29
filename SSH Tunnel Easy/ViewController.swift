//
//  ViewController.swift
//  SSH Tunnel Easy
//
//  Created by TopCaver on 16/4/15.
//  Copyright © 2016年 TopCaver. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    var sshTunnelList = [SshTunnel]()
    
    var statusBar:NSStatusBar?
    var statusBarItem:NSStatusItem?
    var statusBarButton:NSStatusBarButton?
    var statusBarMenu:NSMenu?
    
    var tunnelConnectTask:NSTask?=nil
    
    // MARK: IBOutlet
    @IBOutlet weak var TestButton: NSButton!
    @IBOutlet weak var TunnelListTableView: NSTableView!
    @IBOutlet weak var TunnelListSegmentedControl: NSSegmentedControl!
    
    @IBOutlet weak var TunnelNameTextField: NSTextField!
    @IBOutlet weak var TunnelLocalPortTextField: NSTextField!
    @IBOutlet weak var TunnelHostTextField: NSTextField!
    @IBOutlet weak var TunnelPortTextField: NSTextField!
    @IBOutlet weak var TunnelUsernameTextField: NSTextField!
    @IBOutlet weak var TunnelPasswordTextField: NSSecureTextField!
    @IBOutlet weak var CommandLineLabel: NSTextFieldCell!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
        TunnelListTableView.setDataSource(self)
        TunnelListTableView.setDelegate(self)
        
        // Tunnle Details Text Field Delegate
        TunnelNameTextField.delegate = self
        TunnelLocalPortTextField.delegate = self
        TunnelHostTextField.delegate = self
        TunnelPortTextField.delegate = self
        TunnelUsernameTextField.delegate = self
        TunnelPasswordTextField.delegate = self

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: StatusBar
    func addStatusBarItem(){
        statusBar = NSStatusBar.systemStatusBar()
        statusBarItem = statusBar!.statusItemWithLength(NSVariableStatusItemLength)
        
        statusBarButton = statusBarItem!.button!
        statusBarButton?.title = "SSH"
        statusBarButton?.action = #selector(ViewController.onClick(_:))

        // 构建菜单
        statusBarMenu = NSMenu.init(title: "SSH")
        statusBarMenu?.addItemWithTitle("Hi", action: #selector(ViewController.onClick(_:)), keyEquivalent: "")
        
        let subMenu = NSMenu.init(title: "sub")
        subMenu.addItemWithTitle("world", action: #selector(ViewController.onClick(_:)), keyEquivalent: "")
        statusBarMenu?.setSubmenu(subMenu, forItem: (statusBarMenu?.itemAtIndex(0))!)
        statusBarItem?.menu = statusBarMenu
    }
    
    func onClick(sender:NSButton) {
        NSLog("onclick \(sender.title)")
    }

    //MARK: IBAction
    @IBAction func TestButtonAction(sender: NSButton) {
        NSLog("onclick \(sender.title)")
        addStatusBarItem()
    }
    
    @IBAction func TunnelListSegmentedControlAction(sender: AnyObject) {
        let segmentControl = sender as! NSSegmentedControl
        switch segmentControl.integerValue{
        case 0:
            // Add a new ssh tunnel
            let newSshTunnel = SshTunnel("new ssh tunnel")
            sshTunnelList.append(newSshTunnel!)
            saveSshTunnelList()
            TunnelListTableView.reloadData()
        case 1:
            // remove a selected ssh tunnel
            let selectedSshTunnel = TunnelListTableView.selectedRow
            sshTunnelList.removeAtIndex(selectedSshTunnel)
            saveSshTunnelList()
            TunnelListTableView.reloadData()
        default: break
            // pass
        }
    }
    
    @IBAction func TunnelConncet(sender: NSButton) {
        if TunnelListTableView.selectedRow >= 0 && TunnelListTableView.selectedRow < sshTunnelList.count{
            let currentSshTunnel = sshTunnelList[TunnelListTableView.selectedRow]
            if let (cmd,args) = currentSshTunnel.commandLineString(){
//                self.tunnelConnectTask = NSTask.launchedTaskWithLaunchPath(cmd, arguments: args)
//                print(self.tunnelConnectTask!.processIdentifier)
                print(cmd,args)
                currentSshTunnel.connect()
            }
        }
    }
    
    //MARK: TextField Delegate
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        // Auto Save Thunnel Config
        var currentSshTunnel:SshTunnel?
        if TunnelListTableView.selectedRow >= 0 && TunnelListTableView.selectedRow < sshTunnelList.count{
            currentSshTunnel = sshTunnelList[TunnelListTableView.selectedRow]
        }else{
            return false
        }
        if let fieldId = control.identifier {
            switch fieldId {
            case "TunnelNameTextField":
                currentSshTunnel?.name = control.stringValue
            case "TunnelHostTextField":
                currentSshTunnel?.host = control.stringValue
            case "TunnelLocalPortTextField":
                currentSshTunnel?.localPort = control.stringValue
            case "TunnelPortTextField":
                currentSshTunnel?.port = control.stringValue
            case "TunnelUsernameTextField":
                currentSshTunnel?.username = control.stringValue
            case "TunnelPasswordTextField":
                currentSshTunnel?.password = control.stringValue
            default:
                break
            }
        }
        // print("\(control.identifier) : \(control.stringValue)")
        saveSshTunnelList()
        return true
    }
    
    
    //MARK: Table Delegate
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return sshTunnelList.count
    }
    
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return sshTunnelList[row].name
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let tableView = notification.object as? NSTableView{
            if tableView.selectedRow >= 0 && tableView.selectedRow < sshTunnelList.count{
                TunnelNameTextField.stringValue = sshTunnelList[tableView.selectedRow].name
                TunnelHostTextField.stringValue = sshTunnelList[tableView.selectedRow].host ?? ""
                TunnelPortTextField.stringValue = sshTunnelList[tableView.selectedRow].port ?? ""
                TunnelLocalPortTextField.stringValue = sshTunnelList[tableView.selectedRow].localPort ?? ""
                TunnelUsernameTextField.stringValue = sshTunnelList[tableView.selectedRow].username ?? ""
                TunnelPasswordTextField.stringValue = sshTunnelList[tableView.selectedRow].password ?? ""
                if let (cmdPath,cmdArgs) = sshTunnelList[tableView.selectedRow].commandLineString() {
                    CommandLineLabel.stringValue = "\(cmdPath) " + cmdArgs.joinWithSeparator(" ")
                }
                
            }
        }
    }
    
    // MARK: save & load
    func saveSshTunnelList(){
        let tunnelData = NSKeyedArchiver.archivedDataWithRootObject(sshTunnelList)
        NSUserDefaults().setObject(tunnelData, forKey: "TunnelData")
    }
    
    func loadSshTunnelList()->[SshTunnel]? {
        if let tunnelData = NSUserDefaults().dataForKey("TunnelData") {
            return NSKeyedUnarchiver.unarchiveObjectWithData(tunnelData) as? [SshTunnel]
        } else {
            return nil
        }
    }
    
    func loadData(){
        if let savedSshTunnelList = loadSshTunnelList(){
            sshTunnelList += savedSshTunnelList
        }else{
            let sampleData = SshTunnel("topcaver.com")!
            sshTunnelList += [sampleData]
        }
    }
}

