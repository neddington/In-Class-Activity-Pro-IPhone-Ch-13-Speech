//
//  ContentView.swift
//  In-Class Activity Pro IPhone Ch 13 Speech
//
//  Created by Eddington, Nick on 11/29/23.
//

import SwiftUI
import Speech
struct ContentView: View {
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State var request = SFSpeechAudioBufferRecognitionRequest()
    @State var recognitionTask : SFSpeechRecognitionTask?
    @State var message = ""
    @State var newColor: Color = .white
    var body: some View {
        VStack (spacing: 25) {
            Button {
                recognizeSpeech()
            } label: {
                Text("Start recording")
            }
            TextField("Spoken text appears here", text: $message)
            Button {
                message = ""
                newColor = .white
                stopSpeech()
            } label: {
                Text("Stop recording")
            }
        }.background(newColor)
    }
    func checkSpokenCommand (commandString: String) {
            switch commandString {
            case "Purple":
                newColor = .purple
            case "Green":
                newColor = .green
            case "Yellow":
                newColor = .yellow
            case "Start":
                recognizeSpeech()
            case "Stop":
                stopSpeech()
            default:
                newColor = .white
            }
        }
    func stopSpeech() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    func recognizeSpeech() {
        let node = audioEngine.inputNode
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print (error)
        }
        guard let recognizeMe = SFSpeechRecognizer() else {
            return
        }
        if !recognizeMe.isAvailable {
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                let transcribedString = result.bestTranscription.formattedString
                message = transcribedString
                checkSpokenCommand(commandString: transcribedString)
            } else if let error = error {
                print(error)
            }
        })
    }
}


#Preview {
    ContentView()
}
