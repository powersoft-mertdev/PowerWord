//ContentView:

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var text: String = ""
    @State private var fontSize: CGFloat = 16
    @State private var fontName: String = "System"
    @State private var showFontPicker = false
    @State private var showFileImporter = false
    @State private var showFileExporter = false
    @State private var documentURL: URL?
    
    let availableFonts = ["System", "Courier", "Helvetica", "Times New Roman"]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { showFileImporter = true }) {
                    Label("Open", systemImage: "folder")
                }
                .padding()
                
                Button(action: { showFileExporter = true }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .padding()
                
                Button(action: { showFontPicker.toggle() }) {
                    Label("Font", systemImage: "textformat")
                }
                .padding()
            }
            
            TextEditor(text: $text)
                .font(.custom(fontName, size: fontSize))
                .padding()
                .border(Color.gray, width: 1)
                .padding()
            
            if showFontPicker {
                Picker("Select Font", selection: $fontName) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.plainText]) { result in
            switch result {
            case .success(let url):
                if let content = try? String(contentsOf: url) {
                    text = content
                    documentURL = url
                }
            case .failure(let error):
                print("Failed to open file: \(error)")
            }
        }
        .fileExporter(isPresented: $showFileExporter, document: TextDocument(text: text), contentType: .plainText) { result in
            if case .failure(let error) = result {
                print("Failed to save file: \(error)")
            }
        }
        .padding()
    }
}

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: text.data(using: .utf8) ?? Data())
    }
}

struct PowerWordApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


//MyApp:

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
