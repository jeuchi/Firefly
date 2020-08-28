/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The camera preview view that displays the capture output.
*/

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
