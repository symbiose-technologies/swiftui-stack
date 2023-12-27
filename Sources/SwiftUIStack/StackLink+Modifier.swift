//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
//
// Created by: Ryan Mckinney on 12/27/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI


public extension View {
    
    @ViewBuilder
    func presentsStackDestination<Transition: StackTransition, Destination: View>(
        target: StackLookupStragety = .current,
        transition: Transition,
        isPresented: Binding<Bool>,
        @ViewBuilder destination:  @escaping () -> Destination
    ) -> some View {
        self
            .modifier(
                StackLinkModifier(
                    target: target,
                    transition: transition,
                    isPresented: isPresented,
                    destination: destination
                )
            )
    }
    
}

public struct StackLinkModifier<Transition: StackTransition, Destination: View>: ViewModifier {
    
    // to trigger update entirely
    @EnvironmentObject private var dummy_context: _StackContext

    @Environment(\.stackContext) private var context
    @Environment(\.stackNamespaceID) private var namespaceID

    /// pushing or not
    @State var isActive = false
    @State var currentIdentifier: _StackedViewIdentifier?

    private let target: StackLookupStragety
    private let transition: Transition
    private let destination: () -> Destination

//    var isPresented: Binding<Bool>
    @Binding var isPresented: Bool
    
    private var linkEnvironments: LinkEnvironmentValues = .init()

    
    public init(
      target: StackLookupStragety = .current,
      transition: Transition,
      isPresented: Binding<Bool>,
      @ViewBuilder destination:  @escaping () -> Destination
    ) {
      self.target = target
      self._isPresented = isPresented
        
      self.transition = transition
      self.destination = destination
        self._isActive = .init(initialValue: isPresented.wrappedValue)
        let isInitialPresented = isPresented.wrappedValue
        print("isInitialPresented: \(isInitialPresented)")
        self._initialIsPresented = .init(initialValue: isInitialPresented)

    }
    @State var initialIsPresented: Bool
    
    public func body(content: Content) -> some View {
        content
//            .background {
//                Rectangle()
//                    .fill(Color.clear)
//            }
            .onChange(of: isPresented) { newValue in
                print("onChange(of: isPresented: \(newValue) currentIdentifier: \(currentIdentifier) isActive: \(isActive) context: \(context)")
                if newValue {
                    self.executePresentation()
                } else {
                    if let currentIdentifier {
                        self.currentIdentifier = nil
                    }
//                    self.executeDismissal()
                }
//                if isActive != newValue {
//                    if newValue {
//                        self.executePresentation()
//                    } else {
//                        self.executeDismissal()
//                    }
//                }
            }
//            .task(id: self.context) {
//                do {
//                    if initialIsPresented {
//                        //sleep for 0.1 second
//                        try await Task.sleep(nanoseconds: 100_000_000)
//                        self.executePresentation()
//                    }
//                    
//                } catch {
//                    Log.error(.stack, "Error sleeping: \(error)")
//
//                }
//            }
    }
    func executeDismissal() {
        guard let currentIdentifier else {
            Log.error(.stack, "Attempted to pop view in Stack, but found no current identifier")
            return
        }
        
        guard let context = context?.lookup(strategy: target) else {
          Log.error(.stack, "Attempted to pop view in Stack, but found no context")
          return
        }
        
        
        // TODO: make this can be customized.
        let transaction = Transaction(animation: .spring(
          response: 0.4,
          dampingFraction: 1,
          blendDuration: 0
        ))

        withTransaction(transaction) {
//            self.isActive = false
//            self.isPresented = false
            print("pre context.pop -- currentIdentifier: \(currentIdentifier) isPresented: \(isPresented) isActive: \(isActive)")
            self.isPresented = false
            self.currentIdentifier = nil
            context.pop(identifier: currentIdentifier)
        }
        
        
        
    }
    
    func executePresentation() {
        
        guard let context = context?.lookup(strategy: target) else {
          Log.error(.stack, "Attempted to push view in Stack, but found no context")
          return
        }

        // TODO: make this can be customized.
        let transaction = Transaction(animation: .spring(
          response: 0.4,
          dampingFraction: 1,
          blendDuration: 0
        ))

        withTransaction(transaction) {

            let id = context.push(isPresented: $isPresented,
                                  destination: destination(),
                                  transition: transition,
            linkEnvironmentValues: linkEnvironments
            )
            
//            let id = context.push(
//              destination: destination(),
//              transition: transition,
//              linkEnvironmentValues: linkEnvironments
//            )
            
            self.currentIdentifier = id
//            self.isActive = true
            
//            return
//          }

        }
    }
    
    
    
    public func linkEnvironment<Value>(
      _ keyPath: WritableKeyPath<LinkEnvironmentValues, Value>,
      value: Value
    ) -> Self {
      var modified = self
      modified.linkEnvironments[keyPath: keyPath] = value
      return modified
    }
}
