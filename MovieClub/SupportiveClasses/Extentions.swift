//
//  MovieShimmer.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit

extension UIImageView {
    func load(url: URL, completionBlock:@escaping ()->Void) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    completionBlock()
                }
            }
        }
    }
}

extension UIDevice {
    static func isIpad() -> Bool {
        return self.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
}
