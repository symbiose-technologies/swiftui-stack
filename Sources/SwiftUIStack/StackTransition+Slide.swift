import SwiftUI
import SwiftUISnapDraggingModifier
import SwiftUISupport

extension StackTransition where Self == StackTransitions.Slide {

  public static var slide: Self {
      .init(conf: .defaultHorizontal)
  }
    public static var slideVertical: Self {
        .init(conf: .defaultVertical)
    }
    
    public static func slideWithConf(conf: StackTransitions.Slide.Conf) -> Self {
        .init(conf: conf)
    }

}

extension StackTransitions {

  public struct Slide: StackTransition {

      
      public struct Conf {
          public var sourceAnchor: UnitPoint = .leading
          public var sourceTransitionEdge: Edge = .trailing
          public var dragGestureActivation: SnapDraggingModifier.Activation = .init(minimumDistance: 20, regionToActivate: .screen)
          public var dragGestureAxis: Axis.Set = .horizontal
          public var dragGestureHorizBoundary: SnapDraggingModifier.Boundary = .init(min: 0, max: .infinity, bandLength: 0)
          
          public var dragGestureVerticalBoundary: SnapDraggingModifier.Boundary = .infinity
          public var dragGestureMode: SnapDraggingModifier.GestureMode = .highPriority
          public var isHorizontal: Bool = true
          
          public static var defaultHorizontal: Conf {
              return .init(sourceAnchor: .leading, sourceTransitionEdge: .trailing, dragGestureActivation: .init(minimumDistance: 20, regionToActivate: .screen), dragGestureAxis: .horizontal)
          }
          public static var defaultVertical: Conf {
                return .init(sourceAnchor: .top,
                             sourceTransitionEdge: .bottom,
                             dragGestureActivation: .init(minimumDistance: 20, regionToActivate: .screen),
                             dragGestureAxis: .vertical,
                             dragGestureHorizBoundary: .infinity,
                             
                             dragGestureVerticalBoundary: .init(min: 0, max: .infinity, bandLength: 0),
                             dragGestureMode: .normal,
                             isHorizontal: false
                )
          }
          
          
      }
      
    private struct _LabelModifier: ViewModifier {

      func body(content: Content) -> some View {
        content
      }
    }
      
    let conf: Conf


    private struct _DestinationModifier: ViewModifier {

      let context: DestinationContext

      @Environment(\.stackNamespaceID) var stackNamespace

      /// available in Stack
      @Environment(\.stackUnwindContext) var unwindContext

        
        let conf: Conf
        
      private func hEffectIdentifier() -> MatchedGeometryEffectIdentifiers.EdgeTrailing {
        switch context.backgroundContent {
        case .root:
          return .init(content: .root)
        case .stacked(let id):
          return .init(content: .stacked(id))
        }
      }
        
        
      private func vEffectIdentifier() -> MatchedGeometryEffectIdentifiers.EdgeBottom {
        switch context.backgroundContent {
        case .root:
          return .init(content: .root)
        case .stacked(let id):
          return .init(content: .stacked(id))
        }
      }
        
        

      func body(content: Content) -> some View {

        content
//          .matchedGeometryEffect(
//            id: hEffectIdentifier(),
//            in: stackNamespace!,
//            properties: conf.isHorizontal ? .frame : [],
//            anchor: conf.isHorizontal ? conf.sourceAnchor : .center,
//            isSource: true
//          )
          .matchedGeometryEffect(
            id: vEffectIdentifier(),
            in: stackNamespace!,
            properties: conf.isHorizontal ? [] : .frame,
            anchor: conf.sourceAnchor,
            isSource: true
          )
          .transition(
            .move(edge: conf.sourceTransitionEdge).animation(
              .spring(response: 0.6, dampingFraction: 1, blendDuration: 0)
            )
          )
          .modifier(
            SnapDraggingModifier(
                activation: conf.dragGestureActivation,
//                activation: .init(minimumDistance: 20, regionToActivate: .edge(.leading)),
                axis: conf.dragGestureAxis,
                horizontalBoundary: conf.dragGestureHorizBoundary,
                verticalBoundary: conf.dragGestureVerticalBoundary,
              springParameter: .interpolation(mass: 1.0, stiffness: 500, damping: 500),
                gestureMode: conf.dragGestureMode,
              handler: .init(onEndDragging: { velocity, offset, contentSize in

                  let velValue = conf.isHorizontal ? velocity.dx : velocity.dy
                  let offsetVal = conf.isHorizontal ? offset.width : offset.height
                  let contentSizeVal = conf.isHorizontal ? contentSize.width : contentSize.height
                  print("velValue: \(velValue) offsetVal: \(offsetVal) contentSizeVal: \(contentSizeVal)")
                if velValue > 50 || offsetVal > (contentSizeVal / 2) {

                  // waiting for animation to complete
                  Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 280_000_000)
                    unwindContext?.pop()
                  }
                    if conf.isHorizontal {
                        return .init(width: contentSize.width, height: 0)
                    } else {
                        return .init(width: 0, height: contentSize.height)
                    }
                } else {
                  return .zero
                }
              })
            )
          )
      }
    }

    public func labelModifier() -> some ViewModifier {
      _LabelModifier()
    }

    public func destinationModifier(context: DestinationContext) -> some ViewModifier {
        _DestinationModifier(context: context, conf: conf)
    }
  }

}
