import UIKit
import MZDownloadManager

extension MZUtility {
    
    static func convertSecondsToHHMMSS(seconds : Double) -> (Int, Int, Int) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return ( Int(hr), Int(min), Int(60 * secf) )
    }
    
    static func calculateDuration(_ duration: Double) -> String {
        let (h, m, s) = convertSecondsToHHMMSS(seconds: duration)
        
        return String(format: "%02d:%02d:%02d", h, m, s)        
    }
}
