import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var exportText = ""
    @State private var importText = ""
    @State private var importMessage = ""
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            Section("로컬 데이터 내보내기") {
                Button("JSON 만들기") { exportText = store.exportJSON() }
                TextEditor(text: $exportText)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 180)
            }

            Section("로컬 JSON 가져오기") {
                TextEditor(text: $importText)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 140)
                Button("가져오기") { importMessage = store.importJSON(importText) ? "가져오기를 완료했습니다." : "가져오기에 실패했습니다." }
                if !importMessage.isEmpty { Text(importMessage).foregroundStyle(.secondary) }
            }

            Section("테마") {
                Picker("테마", selection: .constant("calm")) {
                    Text("Calm").tag("calm")
                    Text("System").tag("system")
                }
                .disabled(true)
                Text("테마 설정은 이후 확장을 위한 자리입니다.").font(.caption).foregroundStyle(.secondary)
            }

            Section("데이터 초기화") {
                Button("시드 데이터로 초기화", role: .destructive) { showingResetAlert = true }
            }

            Section("앱 정보") {
                LabeledContent("이름", value: "nou ae")
                LabeledContent("저장 방식", value: "Local JSON")
                LabeledContent("동기화", value: "없음")
                LabeledContent("계정", value: "없음")
            }

            if let error = store.lastStorageError {
                Section("저장 상태") { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("설정")
        .alert("데이터를 초기화할까요?", isPresented: $showingResetAlert) {
            Button("취소", role: .cancel) {}
            Button("초기화", role: .destructive) {
                store.resetData()
                exportText = ""
                importText = ""
            }
        } message: {
            Text("현재 로컬 데이터가 시드 데이터로 대체됩니다.")
        }
    }
}
