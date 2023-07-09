//
//  File.swift
//  notif2
//
//  Created by Kojo Gambrah on 5/27/23.
//

import Foundation

//
//  Untitled.swift
//  MyProject
//
//  Designed in DetailsPro
//  Copyright © (My Organization). All rights reserved.
//

import SwiftUI

struct Untitled: View {
    var body: some View {
        VStack {
            Text("What's New in Keynote")
                .font(.system(.largeTitle, weight: .bold))
                .frame(width: 240)
                .clipped()
                .multilineTextAlignment(.center)
                .padding(.top, 82)
                .padding(.bottom, 52)
            VStack(spacing: 28) {
                ForEach(0..<5) { _ in // Replace with your data model here
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .font(.system(.title, weight: .regular))
                            .frame(width: 60, height: 50)
                            .clipped()
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Collaborate in Messages")
                                .font(.system(.footnote, weight: .semibold))
                            Text("Easily share, discuss, and see updates about your presentation.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Complete feature list")
                Image(systemName: "chevron.forward")
                    .imageScale(.small)
            }
            .padding(.top, 32)
            .foregroundColor(.blue)
            .font(.subheadline)
            Spacer()
            Text("Continue")
                .font(.system(.callout, weight: .semibold))
                .padding()
                .frame(maxWidth: .infinity)
                .clipped()
                .foregroundColor(.white)
                .background(.blue)
                .mask { RoundedRectangle(cornerRadius: 16, style: .continuous) }
                .padding(.bottom, 60)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 130)
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .padding(.top, 53)
        .padding(.bottom, 0)
        .padding(.horizontal, 29)
        .overlay(alignment: .top) {
            HStack {
                Text("9:41")
                    .frame(width: 109)
                    .clipped()
                    .font(.system(.body, weight: .semibold))
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "cellularbars")
                        .imageScale(.small)
                    Image(systemName: "wifi")
                        .imageScale(.small)
                    Image(systemName: "battery.100")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(.body, weight: .light))
                }
                .frame(width: 109)
                .clipped()
                .font(.system(.body, weight: .semibold))
            }
            .padding(.horizontal)
            .padding(.top, 5)
            .frame(maxWidth: .infinity)
            .clipped()
            .frame(height: 53)
            .clipped()
        }
    }
}

struct Untitled_Previews: PreviewProvider {
    static var previews: some View {
        Untitled()
    }
}
