import SwiftUI
import Testing

@testable import MTGLifeCounter

@Suite("Hexagon Shape Tests")
struct HexagonShapeTests {

  @Test("HexagonShape creates a valid path")
  func hexagonCreatesPath() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    let path = hexagon.path(in: rect)

    #expect(!path.isEmpty)
  }

  @Test("HexagonShape path is closed")
  func hexagonPathIsClosed() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    let path = hexagon.path(in: rect)

    // Path should have content
    let bounds = path.boundingRect
    #expect(bounds.width > 0)
    #expect(bounds.height > 0)
  }

  @Test("HexagonShape adapts to different rect sizes")
  func hexagonAdaptsToDifferentSizes() {
    let hexagon = HexagonShape()

    let smallRect = CGRect(x: 0, y: 0, width: 50, height: 50)
    let smallPath = hexagon.path(in: smallRect)
    let smallBounds = smallPath.boundingRect

    let largeRect = CGRect(x: 0, y: 0, width: 200, height: 200)
    let largePath = hexagon.path(in: largeRect)
    let largeBounds = largePath.boundingRect

    #expect(largeBounds.width > smallBounds.width)
    #expect(largeBounds.height > smallBounds.height)
  }

  @Test("HexagonShape centers in rect")
  func hexagonCentersInRect() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    let path = hexagon.path(in: rect)
    let bounds = path.boundingRect

    // The hexagon should be roughly centered
    let centerX = bounds.midX
    let centerY = bounds.midY

    // Allow for some floating point tolerance
    #expect(abs(centerX - rect.midX) < 1.0)
    #expect(abs(centerY - rect.midY) < 1.0)
  }

  @Test("HexagonShape handles non-square rects")
  func hexagonHandlesNonSquareRect() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
    let path = hexagon.path(in: rect)

    #expect(!path.isEmpty)

    let bounds = path.boundingRect
    #expect(bounds.width > 0)
    #expect(bounds.height > 0)
  }

  @Test("HexagonShape with zero width rect")
  func hexagonWithZeroWidthRect() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 0, height: 100)
    let path = hexagon.path(in: rect)

    // Should still create a path, though it will be degenerate
    let bounds = path.boundingRect
    #expect(bounds.width == 0)
  }

  @Test("HexagonShape with zero height rect")
  func hexagonWithZeroHeightRect() {
    let hexagon = HexagonShape()
    let rect = CGRect(x: 0, y: 0, width: 100, height: 0)
    let path = hexagon.path(in: rect)

    // Should still create a path, though it will be degenerate
    let bounds = path.boundingRect
    #expect(bounds.height == 0)
  }
}
