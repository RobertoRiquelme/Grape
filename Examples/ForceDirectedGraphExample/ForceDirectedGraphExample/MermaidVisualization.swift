//
//  MermaidVisualization.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 1/6/24.
//

import SwiftUI
import RegexBuilder
import Grape
import simd
import Observation

@Observable
final class MermaidModel {
    var graphSyntax: String = """
                              Alice → Bob
                              Bob → Cindy
                              Cindy → David
                              David → Emily
                              Emily → Frank
                              Frank → Grace
                              Grace → Henry
                              Henry → Isabella
                              Isabella → Jack
                              Jack → Karen
                              Karen → Liam
                              Liam → Monica
                              Monica → Nathan
                              Nathan → Olivia
                              Olivia → Peter
                              Peter → Quinn
                              Quinn → Rachel
                              Rachel → Steve
                              Steve → Tiffany
                              Tiffany → Umar
                              Umar → Violet
                              Violet → William
                              William → Xavier
                              Xavier → Yolanda
                              Yolanda → Zack
                              Zack → Alice
                              Jack -> Rachel
                              Xavier -> José
                              José -> アキラ
                              アキラ -> Liam
                              """
    
    var tappedNode: String? = nil
    
    var parsedGraph: ([String], [(String, String)]) {
        parseMermaid(graphSyntax)
    }
}

struct MermaidVisualization: View {
    
    @State private var model: MermaidModel = .init()
    
    // the view for label
    @ViewBuilder
    func getLabel(_ text: String) -> some View {
        
        let accentColor = colors[Int(UInt(truncatingIfNeeded: text.hashValue) % UInt(colors.count))]
        
        Text(text)
            .font(.caption)
            .foregroundStyle(.foreground)
            .padding(.vertical, 4.0)
            .padding(.horizontal, 8.0)
            .background(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerSize: .init(width: 12, height: 12))
                        .fill(.background)
                        .shadow(radius: 1.5, y: 1.0)
                    RoundedRectangle(cornerSize: .init(width: 12, height: 12))
                        .stroke(accentColor, style: .init(lineWidth: 2.0))
                }
            }
            .padding()
    }
    
    var body: some View {
        let parsedGraph = model.parsedGraph
        ForceDirectedGraph {
            Series(parsedGraph.0) { node in
                NodeMark(id: node)
                    .symbol(.circle)
                    .symbolSize(radius: 16)
                    .foregroundStyle(Color(white: 1.0, opacity: 0.0))
                    .richLabel(node, alignment: .center, offset: .zero) {
                        getLabel(node)
                    }
            }
            Series(parsedGraph.1) { link in
                LinkMark(from: link.0, to: link.1)
            }
            .linkShape(.arrow)
            .stroke(.black, StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            
        } force: {
            .manyBody()
            .link(originalLength: 50.0)
            .center()
        } emittingNewNodesWithStates: { id in
            KineticState(position: getInitialPosition(id: id, r: 100))
        }
        .graphOverlay(content: { proxy in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .withGraphDragGesture(proxy, of: String.self)
                .onTapGesture { value in
                    if let nodeID = proxy.node(of: String.self, at: value) {
                        model.tappedNode = nodeID
                    }
                }
        })
        .ignoresSafeArea()
        #if !os(visionOS)
        .inspector(isPresented: .constant(true)) {
            MermaidInspector(model: model)
        }
        #endif
    }
}

struct MermaidInspector: View {
    
    @State var model: MermaidModel
    
    init(model: MermaidModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Text("Tapped: \(model.tappedNode ?? "nil")")
                .font(.title2)
            
            Divider()
            
            Text("Edit the mermaid syntaxes to update the graph")
                .font(.title2)
            TextEditor(text: $model.graphSyntax)
                .fontDesign(.monospaced)
            
        }.padding(.top)
    }
}




let multipleNodeRegex = Regex {
    "{"
    ZeroOrMore(.whitespace)
    ZeroOrMore {
        Capture (OneOrMore(.word))
        ZeroOrMore(.whitespace)
        ","
        ZeroOrMore(.whitespace)
    }
    Capture (OneOrMore(.word))
    ZeroOrMore(.whitespace)
    "}"
}

let singleNodeRegex = Regex {
    Capture( OneOrMore(.word) )
}

let mermaidLinkRegex = Regex {
    singleNodeRegex
    OneOrMore(.whitespace)
    ChoiceOf {
        "-->"
        "<--"
        "—>"
        "<—"
        "->"
        "<-"
        "→"
    }

    OneOrMore(.whitespace)
    singleNodeRegex
}

func parseMermaid(
    _ text: String
) -> ([String], [(String, String)]) {
    let links = text.split(separator: "\n")
        .compactMap {
            if let results = $0.matches(of: mermaidLinkRegex).first {
                return (String(results.output.1), String(results.output.2))
            }
            return nil
        }
    let nodes = Array(Set(links.flatMap { [$0.0, $0.1] }))
    return (nodes, links)
}


func getInitialPosition(id: String, r: Double) -> SIMD2<Double> {
    if let firstLetter = id.first?.unicodeScalars.first {
        let deg = Double(firstLetter.value % 26) / 26 * 2 * .pi
        return [cos(deg) * r, sin(deg) * r]
    }
    return .zero
}
