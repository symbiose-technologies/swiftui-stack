import FluidInterfaceKit
@_exported import Stack
import Stack
import SwiftUI

public typealias FluidStack<Data, Root: View> = _Stack<Data, Root, FluidStackDisplaying<Root>>

public struct FluidStackDisplaying<Root: View>: UIViewControllerRepresentable, StackDisplaying {

  public typealias UIViewControllerType = FluidStackController

  private let root: Root
  private let stackedViews: [StackedView]

  public init(
    root: Root,
    stackedViews: [StackedView]
  ) {
    self.root = root
    self.stackedViews = stackedViews
  }

  private func makeController(view: StackedView) -> FluidViewController {

    let body = _FluidStackHostingController(stackedView: view)

    let controller = FluidViewController(
      content: .init(
        bodyViewController: body
      ),
      configuration: .init(
        transition: .empty,
        topBar: .navigation(.default)
      )
    )

    body.navigationItem.leftBarButtonItem = .fluidChevronBackward(onTap: {
      // FIXME:
    })

    return controller
  }

  public func makeUIViewController(context: Context) -> FluidInterfaceKit.FluidStackController {

    // FIXME: identifiers

    let controller = FluidStackController(
      identifier: .init("TODO"),
      view: nil,
      contentView: nil,
      configuration: .init(
        retainsRootViewController: true,
        isOffloadViewsEnabled: true,
        preventsFowardingPop: false
      ),
      rootViewController: FluidViewController.init(
        content: .init(bodyViewController: UIHostingController(rootView: root)),
        configuration: .init(transition: .empty, topBar: .navigation(.default))
      )
    )

    return controller
  }

  public func updateUIViewController(
    _ uiViewController: FluidInterfaceKit.FluidStackController,
    context: Context
  ) {

    let currentItems: [StackedView] = uiViewController.stackingViewControllers.map {
      let hosting =
        ($0 as! FluidViewController).content.bodyViewController as! _FluidStackHostingController
      return hosting.stackedView
    }

    Log.debug(.default, stackedViews)

  }

}

final class _FluidStackHostingController: UIHostingController<EquatableView<StackedView>> {
  
  let stackedView: StackedView

  init(stackedView: StackedView) {
    self.stackedView = stackedView
    super.init(rootView: EquatableView(content: stackedView))
  }

  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

extension CollectionDifference {

  fileprivate func transform<U>(_ transform: (ChangeElement) -> U) -> CollectionDifference<U> {

    let mapped = map { change -> CollectionDifference<U>.Change in
      switch change {
      case .insert(let offset, let element, let associatedWith):
        return .insert(offset: offset, element: transform(element), associatedWith: associatedWith)
      case .remove(let offset, let element, let associatedWith):
        return .remove(offset: offset, element: transform(element), associatedWith: associatedWith)
      }
    }

    return .init(mapped)!

  }

}