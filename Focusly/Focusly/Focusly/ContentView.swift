//
//  ContentView.swift
//  Focusly
//
//  Created by Dmitriy on 04.11.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "pointer.arrow.ipad.rays")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Focusly")
                .font(.largeTitle.bold())
            Text("Фокус на одной задаче за раз")
                .foregroundStyle(.secondary)

            FeatureRow(title: "Задачи", systemImage: "list.clipboard")
            FeatureRow(title: "Таймер", systemImage: "timer")
            FeatureRow(title: "Статистика", systemImage: "chart.bar.xaxis")

            Badge(text: "Смотрим на различные положения модификаторов")
        }
        .padding(40)
        .frame(minWidth: 480, minHeight: 320)

    }
}

#Preview {
    ContentView()
}
