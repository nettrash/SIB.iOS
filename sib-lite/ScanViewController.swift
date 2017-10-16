//
//  ScanViewController.swift
//  sib-lite
//
//  Created by Иван Алексеев on 14.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	@IBOutlet var btnClose: UIButton!
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func failed() {
		let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
		captureSession = nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		switch (AVCaptureDevice.authorizationStatus(for: .video)) {
			case .authorized:
				requestAccessResult(true)
			case .notDetermined:
				AVCaptureDevice.requestAccess(for: .video, completionHandler: requestAccessResult)
			default:
				requestAccessResult(false)
		}
	}
	
	public func requestAccessResult(_ granted: Bool) -> Void {
		if (granted) {
			view.backgroundColor = UIColor.black
			captureSession = AVCaptureSession()
			
			guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
			let videoInput: AVCaptureDeviceInput
			
			do {
				videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
			} catch {
				return
			}
			
			if (captureSession.canAddInput(videoInput)) {
				captureSession.addInput(videoInput)
			} else {
				failed()
				return
			}
			
			let metadataOutput = AVCaptureMetadataOutput()
			
			if (captureSession.canAddOutput(metadataOutput)) {
				captureSession.addOutput(metadataOutput)
				
				metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
				metadataOutput.metadataObjectTypes = [.qr]
			} else {
				failed()
				return
			}
			
			previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
			previewLayer.frame = view.layer.bounds
			previewLayer.videoGravity = .resizeAspectFill
			view.layer.addSublayer(previewLayer)
			
			view.bringSubview(toFront: btnClose)
			
			if (captureSession?.isRunning == false) {
				captureSession.startRunning()
			}
	} else {
			failed()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (captureSession?.isRunning == true) {
			captureSession.stopRunning()
		}
	}
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		captureSession.stopRunning()
		
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			found(code: stringValue)
		}
		
		dismiss(animated: true)
	}
	
	func found(code: String) {
		print(code)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
}


