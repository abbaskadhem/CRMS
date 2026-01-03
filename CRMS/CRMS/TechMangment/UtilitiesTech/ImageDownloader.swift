//
//  ImageDown.swift
//  TechRequestMangment
//
//  Created by Zinab Zooba on 21/12/2025.
//

import UIKit

class ImageDownloader {

    static func downloadAndSaveImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                error == nil,
                let data = data,
                let image = UIImage(data: data)
            else { return }

            // حفظ الصورة في ألبوم الصور
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }.resume()
    }
}
