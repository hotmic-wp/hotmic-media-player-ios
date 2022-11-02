//
//  StreamView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan on 10/31/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI

struct StreamView: View {
    let thumbnailURL: URL?
    let title: String
    let date: Date?
    let state: String
    let hostImageURL: URL?
    let hostName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(
                url: thumbnailURL,
                content: { image in
                    image.resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                        .background(Color(.tertiarySystemFill))
                },
                placeholder: {
                    Color(.tertiarySystemFill)
                        .aspectRatio(16/9, contentMode: .fill)
                }
            )
            .overlay {
                VStack(alignment: .leading) {
                    Text(state)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .foregroundColor(.primary)
                        .background(Color(.systemBackground))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .textCase(.uppercase)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth:.infinity, alignment: .leading)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let date {
                    Text(date.formatted(date: .long, time: .omitted))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                HStack {
                    AsyncImage(
                        url: hostImageURL,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(Circle())
                        },
                        placeholder: {
                            Color(.tertiarySystemGroupedBackground)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                    )
                    
                    Text(hostName)
                        .font(.callout)
                }
                .padding(.top, 6)
            }
            .padding()
        }
        .frame(maxWidth:.infinity, alignment: .leading)
    }
}

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StreamView(thumbnailURL: nil, title: "Preview Stream", date: Date(), state: "LIVE", hostImageURL: nil, hostName: "John Doe")
        }
    }
}
