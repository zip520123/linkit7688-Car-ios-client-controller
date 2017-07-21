//
//  ViewController.swift
//  Slin Car Controller
//
//  Created by 蔡祥霖 on 2016/6/23.
//  Copyright © 2016年 woody_tsai. All rights reserved.
//

import UIKit

class SlinVC: UIViewController , StreamDelegate{
//	var writeStream = CFWriteStream
//	private let serverAddress: CFString = "10.65.165.35"
	fileprivate let serverAddress: CFString = "192.168.100.1" as CFString
	fileprivate let serverPort: UInt32 = 4000
	fileprivate var inputStream: InputStream!
	fileprivate var outputStream: OutputStream!
	@IBOutlet weak var statusLabel: UILabel!
	
	var motor1status = 0 {
		didSet{
			commentSend()
		}
	}
	var motor2status = 0 {
		didSet{
			commentSend()
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
//		statusLabel.text = ""
		initSokcet()
//		_ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.timerSend) , userInfo: nil, repeats: true)
	}
	@IBAction func ledController(){
		let string = "led"
		
		let data = NSData(data: string.data(using: String.Encoding.ascii)!) as Data
		
		outputStream?.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) , maxLength: data.count)
	}
	func commentSend(){

		let string = "slin" + String(motor1status) + String(motor2status)
		
		let data = NSData(data: string.data(using: String.Encoding.ascii)!) as Data
 
			outputStream?.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) , maxLength: data.count)

	}
	@IBAction func connectSocket() {
		self.inputStream.close()
		self.outputStream.close()
		initSokcet()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		
	}
	func initSokcet(){
		var readStream: Unmanaged<CFReadStream>?
		var writeStream: Unmanaged<CFWriteStream>?
		
		CFStreamCreatePairWithSocketToHost(nil, self.serverAddress, self.serverPort, &readStream, &writeStream)
		
		self.inputStream = readStream!.takeRetainedValue()
		self.outputStream = writeStream!.takeRetainedValue()
		
		self.inputStream.delegate = self
		self.outputStream.delegate = self
		
		self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
		self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
		
		self.inputStream.open()
		self.outputStream.open()
	}
	
	@IBAction func upTap(_ sender: UIButton) {
		print(sender.currentTitle!)
		if sender.currentTitle == "▲" {
			motor1status = 1
			
		}
		if sender.currentTitle == "▼" {
			motor1status = 2
		}
		if sender.currentTitle == "<" {
			motor2status = 1
		}
		if sender.currentTitle == ">" {
			motor2status = 2
		}
		
	}
	
	@IBAction func touchUpInside(_ sender: UIButton) {
//		print("upInside")
		if sender.currentTitle == "▲" {
			motor1status = 0
		}
		if sender.currentTitle == "▼" {
			motor1status = 0
		}
		if sender.currentTitle == "<" {
			motor2status = 0
		}
		if sender.currentTitle == ">" {
			motor2status = 0
		}
		
	}
	

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		outputStream.close()
		outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
		outputStream = nil
		
	}
 	func stream(_ aStream: Stream, handle eventCode: Stream.Event){
		switch eventCode{
		case Stream.Event.openCompleted:
			print("Stream opened")
			break
		case Stream.Event.hasSpaceAvailable:
			if outputStream == aStream{
//				print("outputstream is ready!")
			}
			break
		case Stream.Event.hasBytesAvailable:
			print("has bytes")
			if aStream == inputStream{
//				var buffer: UInt8 = 0
//				var len: Int!
//				var readByte :UInt8 = 0
//				while inputStream.hasBytesAvailable {
//					inputStream.read(&readByte, maxLength: 1)
//				}
				
//				while ((inputStream?.hasBytesAvailable) != nil) {
//					len = inputStream?.read(&buffer, maxLength: 1024)
//					if len > 0{
//					var output = NSString(bytes: &buffer, length: len, encoding: NSASCIIStringEncoding)
//						
//						if nil != output{
//							print("Server said: \(output!)")
//							output = output?.substringFromIndex(11)
//						}
//					}
//				}
			}
			break
		case Stream.Event.errorOccurred:
			print("Can not connect to the host!")
			break
		case Stream.Event.endEncountered:
			outputStream.close()
			outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
			outputStream = nil
			break
		default:
			print("Unknown event")
		}
	}
}

