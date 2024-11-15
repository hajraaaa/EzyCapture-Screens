import UIKit

// This extension allows adding linear gradient to UIView

extension UIView {
    func addLinearGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        // Remove any existing gradient layers to avoid overlap
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds

        // Add the gradient layer to the view's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
