//
//  UIImageExtensions.swift
//  sib-lite
//
//  Created by Иван Алексеев on 17.12.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	var grayscale: UIImage? {
		guard let ciImage = CIImage(image: self)?.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0]) else { return nil }
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		defer { UIGraphicsEndImageContext() }
		UIImage(ciImage: ciImage).draw(in: CGRect(origin: .zero, size: size))
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
