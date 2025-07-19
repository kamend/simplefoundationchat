//
//  ChatView.swift
//  Foundation Test
//
//  Created by Kamen Dimitrov on 17.07.25.
//
import SwiftUI
import FoundationModels

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatView : View {
    
    @State private var inputText = ""
    @State private var messages: [Message] = []
    @State private var session: LanguageModelSession?
    @State private var response: String.PartiallyGenerated?
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(text: message.content, isUser: message.isUser, date:message.timestamp)
                                .id(message.id)
                            
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of:messages.count) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
                
            }
            TextField("Chat", text:$inputText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(20)
                .lineLimit(1...5)
                .onSubmit {
                    sendMessage()
                }
                .overlay(
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(inputText.isEmpty ? Color.secondary : Color.accentColor)
                            .cornerRadius(18)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(inputText.isEmpty),
                    alignment: .trailing
                )
                
        }
        .onAppear {
            messages = []
            session = LanguageModelSession(instructions: Instructions("You are a friendly chatbot"))
            session?.prewarm()
        }
    }
    
    private func sendMessage() {
        

        let userMessage = Message(content: inputText, isUser: true, timestamp: Date())
    
        messages.append(userMessage)
        
        Task {
            do {
                try await sendToAI(input:userMessage.content)
            } catch {
                print(error)
            }
        }
        
        inputText = ""
        
        
    }
    
    private func sendToAI(input: String) async throws {
        let prompt = """
            \(input)
            """
        
        print(prompt)
    
        guard let stream = session?.streamResponse(
            generating: String.self,
            options: GenerationOptions(sampling: .random(top: 1)),
            includeSchemaInPrompt: false,
            prompt: {
                Prompt(prompt)
            }
        ) else { return }
        
        for try await partialResponse in stream {
            response = partialResponse
        }
        
        withAnimation {
            messages.append(Message(content: response ?? "", isUser: false, timestamp: Date()))
            response = nil
        }
        
    }
}

#Preview {
    ChatView()
}
