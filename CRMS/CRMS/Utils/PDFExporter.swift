
import Foundation
import UIKit

final class PDFExporter {

    static func exportSegmentsToPDF(segmentViews: [UIView], segmentNames: [String], logo: UIImage?, fileName: String) throws -> URL {

        // A4 size
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)

        //layout constants
        let margin: CGFloat = 28

        //header
        let headerHeight: CGFloat = 92

        //footer
        let footerHeight: CGFloat = 50

        //content space
        let contentRect = CGRect(
            x: margin,
            y: margin + headerHeight,
            width: pageRect.width - (margin * 2),
            height: pageRect.height - (margin * 2) - headerHeight - footerHeight
        )

        //renderer pdf
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        //file directory
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        try renderer.writePDF(to: url) { pdfContext in

            //page counter
            var globalPageNumber = 0

            //fallback names
            let safeNames: [String] = {
                if segmentNames.count == segmentViews.count { 
                    return segmentNames
                }
                return segmentViews.indices.map { 
                    idx in
                    idx < segmentNames.count ? segmentNames[idx] : "Segment \(idx + 1)"
                }
            }()

            // Export segment
            for (segmentIndex, segmentView) in segmentViews.enumerated() {

                //rener full view
                let tallImage = renderFullViewToImageScaledToPDFWidth(
                    view: segmentView,
                    targetWidth: contentRect.width
                )

                //if fails --> balnk page
                let safeTallImage = tallImage ?? blankImage(size: contentRect.size)

                //image tall --> split into 2 pages
                let slices = sliceImageVertically(
                    image: safeTallImage,
                    sliceHeight: contentRect.height
                )

                //each img in a seperate page
                for (sliceIndex, slice) in slices.enumerated() {

                    pdfContext.beginPage()
                    globalPageNumber += 1

                    let cg = pdfContext.cgContext

                    //header
                    drawPDFHeader(context: cg, logo: logo, segmentName: safeNames[segmentIndex],isContinued: sliceIndex > 0)

                    //footer
                    drawPDFFooter(context: cg,pageBounds: pageRect)

                    //img in the center of the page
                    let drawRect = centeredRect(imageSize: slice.size, inside: contentRect)
                    slice.draw(in: drawRect)
                }
            }
        }

        return url
    }

    private static func drawPDFHeader(context: CGContext, logo: UIImage?, segmentName: String, isContinued: Bool) {
        
        context.saveGState()

        // logo
        let logoRect = CGRect(x: 20, y: 20, width: 70, height: 40)
        logo?.draw(in: logoRect)

        //title
        let title = "Performance Analysis Report"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.label
        ]
        title.draw(at: CGPoint(x: 95, y: 30), withAttributes: titleAttributes)

        //segment name
        let segmentText = isContinued ? "\(segmentName) (continued)" : segmentName
        let segmentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        segmentText.draw(at: CGPoint(x: 95, y: 52), withAttributes: segmentAttributes)

        //divider line
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 20, y: 78))
        context.addLine(to: CGPoint(x: 575, y: 78))
        context.strokePath()

        context.restoreGState()
    }

    //footer func
    private static func drawPDFFooter(context: CGContext, pageBounds: CGRect) {
        
        context.saveGState()

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let footerText = "Generated on \(formatter.string(from: Date()))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]

        footerText.draw(at: CGPoint(x: 20, y: pageBounds.height - 22), withAttributes: attributes)

        context.restoreGState()
    }

    private static func renderFullViewToImageScaledToPDFWidth(view: UIView, targetWidth: CGFloat) -> UIImage? {

        //constraints are applied before rendering
        view.layoutIfNeeded()

        // Expand scroll views
        let backups = expandAllScrollViewsInside(view)
        defer { restoreAllScrollViews(backups) }

        view.layoutIfNeeded()

        let originalSize = view.bounds.size
        guard originalSize.width > 0, originalSize.height > 0 else { return nil }

        //fit to PDF width
        let scale = targetWidth / originalSize.width
        let scaledSize = CGSize(width: targetWidth, height: originalSize.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { ctx in
            ctx.cgContext.scaleBy(x: scale, y: scale)
            view.drawHierarchy(in: CGRect(origin: .zero, size: originalSize), afterScreenUpdates: true)
        }
    }

    //original scroll view 
    private struct ScrollBackup {
        weak var scroll: UIScrollView?
        let originalBounds: CGRect
        let originalOffset: CGPoint
    }

    //expands ALL scroll views
    private static func expandAllScrollViewsInside(_ root: UIView) -> [ScrollBackup] {

        let scrolls = findScrollViews(in: root)
        var backups: [ScrollBackup] = []

        for scroll in scrolls {

            scroll.layoutIfNeeded()

            // Make sure table/collection has updated layouts so contentSize is correct
            if let table = scroll as? UITableView {
                table.layoutIfNeeded()
            }

            if let collection = scroll as? UICollectionView {
                collection.setNeedsLayout()
                collection.layoutIfNeeded()
                collection.collectionViewLayout.invalidateLayout()
                collection.collectionViewLayout.prepare()
                collection.layoutIfNeeded()
            }

            let contentSize = scroll.contentSize
            guard contentSize.width > 0, contentSize.height > 0 else { continue }

            // Save original state
            backups.append(
                ScrollBackup(
                    scroll: scroll,
                    originalBounds: scroll.bounds,
                    originalOffset: scroll.contentOffset
                )
            )

            // Expand to full content
            scroll.contentOffset = .zero
            scroll.bounds.size = contentSize
            scroll.layoutIfNeeded()
        }

        return backups
    }

    //restores scroll views back to original frame + offset.
    private static func restoreAllScrollViews(_ backups: [ScrollBackup]) {
        for b in backups {
            guard let scroll = b.scroll else { 
                continue 
            }
            scroll.bounds = b.originalBounds
            scroll.contentOffset = b.originalOffset
            scroll.layoutIfNeeded()
        }
    }

    //finds all scroll views
    private static func findScrollViews(in root: UIView) -> [UIScrollView] {
        var result: [UIScrollView] = []
        for sub in root.subviews {
            if let scroll = sub as? UIScrollView { result.append(scroll) }
            result.append(contentsOf: findScrollViews(in: sub))
        }
        return result
    }

    //crop tall image into multiple images
    private static func sliceImageVertically(image: UIImage, sliceHeight: CGFloat) -> [UIImage] {

        guard let cg = image.cgImage else { return [image] }

        let imgScale = image.scale
        let totalHeightPoints = image.size.height
        let widthPoints = image.size.width

        var slices: [UIImage] = []
        var y: CGFloat = 0

        while y < totalHeightPoints {

            let h = min(sliceHeight, totalHeightPoints - y)

            // Points -> pixels
            let cropRectPixels = CGRect(
                x: 0,
                y: y * imgScale,
                width: widthPoints * imgScale,
                height: h * imgScale
            )

            if let cropped = cg.cropping(to: cropRectPixels) {
                slices.append(UIImage(cgImage: cropped, scale: imgScale, orientation: .up))
            }

            y += h
        }

        return slices.isEmpty ? [image] : slices
    }

    //centers the img in the page
    private static func centeredRect(imageSize: CGSize, inside container: CGRect) -> CGRect {
        let x = container.minX + (container.width - imageSize.width) / 2
        let y = container.minY + (container.height - imageSize.height) / 2
        return CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)
    }

    //blank page for fallback
    private static func blankImage(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

}
