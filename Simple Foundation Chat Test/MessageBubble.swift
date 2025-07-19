//
//  MessageBubble.swift
//  Foundation Test
//
//  Created by Kamen Dimitrov on 17.07.25.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let isUser: Bool
    let date: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date, style: .time)
                    .padding(.leading, 8)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(text)
                     .padding(.horizontal, 16)
                     .padding(.vertical, 12)
                     .background(isUser ? Color.blue : Color.secondary.opacity(0.2))
                     .foregroundColor(isUser ? .white : .primary)
                     .cornerRadius(16)
             }
            Spacer()
        }
        .padding(.horizontal, 16)
           
    }

}
