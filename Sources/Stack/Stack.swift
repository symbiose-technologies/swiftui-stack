import SwiftUI
import Combine
import os.log

extension OSLog {
  
  @inline(__always)
  private static func makeOSLogInDebug(isEnabled: Bool = true, _ factory: () -> OSLog) -> OSLog {
#if DEBUG
    return factory()
#else
    return .disabled
#endif
  }
  
  static let `stack`: OSLog = makeOSLogInDebug { OSLog.init(subsystem: "stack", category: "default") }
}

// MARK: - Libraries

/**
 - TODO:
  - [ ] Path
  - [x] momentary presentation
  - [ ] Nesting support
 
 memo:
 https://www.avanderlee.com/swiftui/navigationlink-programmatically-binding/
 */
@MainActor
public struct Stack<Data, Root: View>: View {
  
  @Backport.StateObject private var context: _StackContext
  
  private let root: Root
  
  private let pathBinding: Binding<StackPath>?
  
  @State private var currentPath: StackPath?
  
  public init(
    @ViewBuilder root: () -> Root
  ) where Data == StackPath {
        
    // TODO: I don't know how to create Binding without data source(State)
    // Instead, context uses two way handlings case of Bindings presents or not.
    self.pathBinding = nil
    self.root = root()
    self._context = .init(wrappedValue: .init())
  }
  
  public init(
    path: Binding<StackPath>,
    @ViewBuilder root: () -> Root
  ) where Data == StackPath {
    
    self.pathBinding = path
    self.root = root()
    self._context = .init(wrappedValue: .init())
  }
  
  public var body: some View {
    
    ZStack {
            
      VStack {
        root
      }
            
      ForEach(context.stackingViews) {
        $0
          .transition(
            AnyTransition.move(edge: .trailing)
          )
          .id($0.id)
      }
      
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    // propagates context to descendants
    .environment(\.stackContext, context)
    .onReceive(context.$path, perform: { path in
      Log.debug(.stack, "Receive \(path)")
      
      pathBinding?.wrappedValue = path
      self.currentPath = path
    })
    .onChangeWithPrevious(of: pathBinding?.wrappedValue, perform: { path, _ in
            
      /*
       Updates current stacking with path changes.
       */

      guard let path, path != self.currentPath else { return }
      
      context.receivePathUpdates(path: path)
    })
    
  }
  
}

/**
 A wrapper view that displays content with identifier which uses on Pop operation.
 */
struct StackedView: View, Identifiable {
  
  enum Associated {
    case value(StackPath.ItemBox)
    case moment(Binding<Bool>)
  }
  
  let id: _StackingIdentifier
  
  private let content: AnyView
  
  let associated: Associated
  
  init(
    associated: Associated,
    identifier: _StackingIdentifier,
    content: some View
  ) {
    self.associated = associated
    self.id = identifier
    self.content = .init(content)
  }
  
  var body: some View {
    content
      .environment(\.stackIdentifier, id)
  }
  
}

// MARK: - View extensions

extension View {
  
  public func stackDestination<D, C>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View where D : Hashable, C : View {
    
    self.modifier(StackEnvironmentModifier(withValue: { context in
      guard let context else {
        return
      }
      context.registerDestination(for: data.self, destination: destination)
    }))
    
  }
  
  public func stackDestination<V>(isPresented: Binding<Bool>, @ViewBuilder destination: @escaping () -> V) -> some View where V : View {
    
    self.modifier(StackMomentaryPushModifier(isPresented: isPresented, destination: destination))
    
  }
  
}

private struct StackMomentaryPushModifier<Destination: View>: ViewModifier {
  
  @Environment(\.stackContext) private var context
  @Binding var isPresented: Bool
  @State var currentIdentifier: _StackingIdentifier?
  let destination: () -> Destination
      
  func body(content: Content) -> some View {
    
    content
      .onChangeWithPrevious(
        of: isPresented,
        perform: { isPresented, _ in
          
          guard let context else {
            return
          }
          
          if isPresented {
            currentIdentifier = context.push(
              binding: $isPresented,
              destination: destination()
            )
          } else {
            
            if let currentIdentifier {
              self.currentIdentifier = nil
              context.pop(identifier: currentIdentifier)
            }
            
          }
          
        }
      )
    
  }
}

private struct StackEnvironmentModifier: ViewModifier {
  
  @Environment(\.stackContext) private var context
  
  private let _withValue: @MainActor (_StackContext?) -> Void
  
  init(withValue: @escaping @MainActor (_StackContext?) -> Void) {
    self._withValue = withValue
  }
  
  func body(content: Content) -> some View {
    return content
      .onAppear {
        _withValue(context)
      }
      .onDisappear {
        // TODO:
      }
  }
}


