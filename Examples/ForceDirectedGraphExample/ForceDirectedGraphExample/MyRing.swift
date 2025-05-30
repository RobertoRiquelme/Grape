//
//  ForceDirectedGraphSwiftUIExample.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI
import ForceSimulation

struct MyRing: View {
    
    @State var graphStates = ForceDirectedGraphState(
        ticksOnAppear: .untilStable
    )
    
    @State var draggingNodeID: Int? = nil
    
    static let storkeStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
    
    var body: some View {
        
        ForceDirectedGraph(states: graphStates) {
            Series(0..<20) { i in
                
                NodeMark(id: 3 * i + 0)
                    .symbolSize(radius: 6.0)
                    .foregroundStyle(.green)
                    .stroke(3*i+0 == draggingNodeID ? .secondary : .clear, Self.storkeStyle)
                    
                NodeMark(id: 3 * i + 1)
                    .symbol(.pentagon)
                    .symbolSize(radius:10)
                    .foregroundStyle(.blue)
                    .stroke(3*i+1 == draggingNodeID ? .secondary : .clear, Self.storkeStyle)
                
                NodeMark(id: 3 * i + 2)
                    .symbol(.circle)
                    .symbolSize(radius:6.0)
                    .foregroundStyle(.yellow)
                    .stroke(3*i+2 == draggingNodeID ? .secondary : .clear, Self.storkeStyle)
                
                LinkMark(from: 3 * i + 0, to: 3 * i + 1)
                LinkMark(from: 3 * i + 1, to: 3 * i + 2)
                LinkMark(from: 3 * i + 0, to: 3 * ((i + 1) % 20) + 0)
                LinkMark(from: 3 * i + 1, to: 3 * ((i + 1) % 20) + 1)
                LinkMark(from: 3 * i + 2, to: 3 * ((i + 1) % 20) + 2)
            }
            .stroke(.secondary, Self.storkeStyle)
            
        } force: {
            .manyBody(strength: -15)
            .link(
                originalLength: 30.0,
                stiffness: .weightedByDegree { _, _ in 1.0 }
            )
            .center()
//            .collide()
        }
        .graphOverlay { proxy in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .withGraphDragGesture(proxy, of: Int.self, action: describe)
                .withGraphMagnifyGesture(proxy)
        }
        .toolbar {
            GraphStateToggle(graphStates: graphStates)
        }
    }
    
    func describe(_ state: GraphDragState<Int>?) {
        switch state {
        case .node(let id):
            if draggingNodeID != id {
                draggingNodeID = id
                print("Dragging \(id)")
            }
        case .background(let start):
            draggingNodeID = nil
            print("Dragging \(start)")
        case nil:
            draggingNodeID = nil
            print("Drag ended")
        }
    }
}
