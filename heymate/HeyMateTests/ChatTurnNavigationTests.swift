import Foundation
import Testing
@testable import HeyMate

@MainActor
@Suite(.serialized)
struct ChatTurnNavigationTests {
    @Test(arguments: ["new", "open", "mate", "delete", "clear", "clearMate"],
          ["approval", "running", "listening", "finalizing"])
    func navigationPreservesUnrelatedStateAfterACompletedReply(action: String, interaction: String) async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let other = fixture.addMate(name: "Pixel", brain: .onDevice)
        let otherChat = fixture.addChat(mateID: other.id)

        // Production keeps the completed task referenced. Navigation must
        // not mistake that old handle for ownership of the new interaction.
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Earlier question", shouldCaptureScreen: false)
        let oldTask = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        fixture.client.finish(text: "")
        await oldTask.value
        #expect(manager.currentResponseTask != nil)
        #expect(!manager.isResponseInFlight)

        let runID = UUID()
        switch interaction {
        case "approval":
            manager.dispatch(.agentStarted(runID))
            manager.dispatch(.approvalRequested(runID))
        case "running": manager.dispatch(.agentStarted(runID))
        case "listening": manager.dispatch(.startListening(.talk))
        default:
            manager.dispatch(.startListening(.talk))
            manager.dispatch(.finishListening)
        }
        manager.isSubscriptionVoiceChatActive = true
        let expectedState = manager.state
        let expectedBusyReason = manager.typedMessageBusyReason
        let expectedForegroundAgent = manager.isForegroundAgentActive
        switch action {
        case "new": manager.startNewChat()
        case "open": manager.openChat(id: otherChat.id)
        case "mate": manager.openMate(id: other.id)
        case "delete": manager.deleteChat(id: manager.currentChat.id)
        case "clear": manager.clearAllChats()
        default: manager.clearChats(forMateID: try #require(manager.currentChat.mateID))
        }
        await Task.yield()
        #expect(manager.state == expectedState)
        #expect(manager.typedMessageBusyReason == expectedBusyReason)
        #expect(manager.isForegroundAgentActive == expectedForegroundAgent)
        #expect(manager.isSubscriptionVoiceChatActive)
    }

    @Test func navigationDuringNewVoiceInputInvalidatesOldReplyWithoutIdlingInput() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Earlier question", shouldCaptureScreen: false)
        let oldTask = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        // The Talk shortcut cancels the previous task before starting the
        // microphone. This provider deliberately has not finished unwinding.
        oldTask.cancel()
        manager.dispatch(.startListening(.talk))
        manager.isSubscriptionVoiceChatActive = true
        manager.startNewChat()
        try await fixture.client.emitChunk("Stale reply")
        fixture.client.finish(text: "Stale answer")
        await oldTask.value
        #expect(manager.currentResponseTask == nil)
        #expect(manager.currentChat.messages.isEmpty)
        #expect(manager.streamingAssistantText.isEmpty)
        #expect(manager.state == .listening(.talk))
        #expect(manager.isSubscriptionVoiceChatActive)
    }

    @Test func navigationClearsLingeringGuidanceWithoutResettingAgentApproval() throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let runID = UUID()
        manager.dispatch(.agentStarted(runID))
        manager.dispatch(.approvalRequested(runID))
        manager.cursorCaptionText = "Earlier lesson step"
        manager.isGuidancePointerHeld = true
        manager.startNewChat()
        #expect(manager.cursorCaptionText.isEmpty)
        #expect(!manager.isGuidancePointerHeld)
        #expect(manager.state == .waitingForApproval(runID))
        #expect(manager.isForegroundAgentActive)
    }

    @Test func navigationBeforeTaskStartsCannotAppendOldQuestion() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Old question", shouldCaptureScreen: false)
        let oldTask = try #require(manager.currentResponseTask)
        manager.isGuidancePointerHeld = true
        manager.cursorCaptionText = "Old step"
        manager.startNewChat()
        await oldTask.value
        #expect(manager.currentChat.messages.isEmpty)
        #expect(fixture.client.requests.isEmpty)
        #expect(manager.state == .idle)
        #expect(!manager.isGuidancePointerHeld)
        #expect(manager.cursorCaptionText.isEmpty)
    }

    @Test(arguments: ["new", "open", "mate", "delete", "clear", "clearMate"])
    func navigationRejectsLateChunksToolsAndErrors(action: String) async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let other = fixture.addMate(name: "Pixel", brain: .onDevice)
        let otherChat = fixture.addChat(mateID: other.id)
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "First question", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        switch action {
        case "new": manager.startNewChat()
        case "open": manager.openChat(id: otherChat.id)
        case "mate": manager.openMate(id: other.id)
        case "delete": manager.deleteChat(id: manager.currentChat.id)
        case "clear": manager.clearAllChats()
        default: manager.clearChats(forMateID: try #require(manager.currentChat.mateID))
        }
        let expectedChat = manager.currentChat
        try await fixture.client.emitChunk("Late answer from previous mate")
        let toolResult = try await fixture.client.requestTool(AssistantToolCall(
            toolUseIdentifier: "late-tool",
            toolName: "unavailable-test-tool",
            inputArgumentsJSON: "{}"
        ))
        #expect(toolResult.isError == true)
        #expect(toolResult.text == "This reply was cancelled. No action was taken.")
        fixture.client.finish(throwing: NSError(domain: "NavigationTest", code: 401))
        await task.value
        #expect(manager.currentChat == expectedChat)
        #expect(manager.streamingAssistantText.isEmpty)
        #expect(manager.state == .idle)
    }

    @Test func lateSuccessfulReplyCannotCreateWorkOrHandoffs() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "First question", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        manager.startNewChat()
        fixture.client.finish(text: "Old answer [WORK: write a file]")
        await task.value
        #expect(manager.currentChat.messages.isEmpty)
        #expect(manager.agentRuns.isEmpty)
        #expect(manager.pendingHandoffs.isEmpty)
    }

    @Test func navigationDismissesTheCancelledTurnsApproval() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let request = ConnectorToolApprovalRequest(
            connectorDisplayName: "Test connector", toolName: "test_action",
            argumentsSummary: "No action will run", risk: .externalSideEffect
        )
        fixture.client.approvalRequest = (manager.connectorToolCoordinator, request)
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Test approval", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        for _ in 0..<100 {
            if manager.connectorToolCoordinator.pendingRequest != nil { break }
            await Task.yield()
        }
        #expect(manager.connectorToolCoordinator.pendingRequest?.id == request.id)
        manager.startNewChat()
        await task.value
        #expect(fixture.client.approvalDecision == false)
        #expect(manager.connectorToolCoordinator.pendingRequest == nil)
    }

    @Test func cancellingAnOlderApprovalDoesNotDismissItsReplacement() async throws {
        let coordinator = ConnectorToolCoordinator()
        let first = ConnectorToolApprovalRequest(
            connectorDisplayName: "First", toolName: "first", argumentsSummary: "None", risk: .externalSideEffect
        )
        let second = ConnectorToolApprovalRequest(
            connectorDisplayName: "Second", toolName: "second", argumentsSummary: "None", risk: .externalSideEffect
        )
        let firstTask = Task { await coordinator.requestApproval(for: first) }
        for _ in 0..<100 {
            if coordinator.pendingRequest?.id == first.id { break }
            await Task.yield()
        }
        let secondTask = Task { await coordinator.requestApproval(for: second) }
        for _ in 0..<100 {
            if coordinator.pendingRequest?.id == second.id { break }
            await Task.yield()
        }
        firstTask.cancel()
        #expect(await firstTask.value == false)
        await Task.yield()
        #expect(coordinator.pendingRequest?.id == second.id)
        coordinator.approvePendingRequest()
        #expect(await secondTask.value == true)
    }

    @Test func openingSavedChatAppliesItsMatesPreferences() throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let mate = fixture.addMate(name: "Pixel", brain: .onDevice, exclusions: ["example-connector"])
        let chat = fixture.addChat(mateID: mate.id)
        fixture.manager.openChat(id: chat.id)
        #expect(fixture.manager.activeMateID == mate.id)
        #expect(fixture.manager.selectedBrain == .onDevice)
        #expect(fixture.manager.chatConnectorExclusions == ["example-connector"])
    }

    @Test func specialistRequestIncludesOwnNoteAndOnlyItsScopedSummary() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        var mate = fixture.addMate(name: "Pixel", brain: .onDevice)
        mate.memoryNote = "Use concise design feedback."
        _ = manager.mateDirectory.upsertMate(mate)
        manager.memoryRepository.updateSessionSummary(mateID: mate.id, text: "Own project is a blue logo.")
        manager.memoryRepository.updateSessionSummary(mateID: UUID(), text: "Private unrelated project is a red boat.")
        manager.memoryItems = manager.memoryRepository.loadAll()
        manager.openMate(id: mate.id)
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Explain the next step", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        let request = try #require(fixture.client.requests.first)
        #expect(request.systemPrompt.contains(mate.memoryNote))
        #expect(request.userPrompt.contains("Own project is a blue logo."))
        #expect(!request.userPrompt.contains("Private unrelated project"))
        manager.startNewChat()
        fixture.client.finish(text: "Stale answer")
        await task.value
    }

    @Test(arguments: [false, true])
    func navigationKeepsBackgroundRoutineInItsOriginalChat(beforeTaskStarts: Bool) async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let worker = fixture.addMate(name: "Scout", brain: .onDevice)
        let workerChat = fixture.addChat(mateID: worker.id)
        let other = fixture.addMate(name: "Pixel", brain: .customAPI)
        manager.backgroundRoutineSession = workerChat
        manager.activeRoutineTurn = ActiveRoutineTurn(
            routineID: UUID(), mateID: worker.id, task: "Routine question", writesIntoOpenChat: false
        )
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Routine question", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        if beforeTaskStarts { manager.openMate(id: other.id) }
        try await fixture.client.waitForRequest()
        if !beforeTaskStarts { manager.openMate(id: other.id) }
        #expect(manager.selectedBrain == .customAPI)
        #expect(manager.conversationBrainForTurn == .onDevice)
        #expect(task.isCancelled == false)
        try await fixture.client.emitChunk("Background result")
        #expect(manager.streamingAssistantText.isEmpty)
        fixture.client.finish(text: "Background result")
        await task.value
        #expect(manager.currentChat.mateID == other.id)
        #expect(manager.currentChat.messages.isEmpty)
        let saved = try #require(manager.chatHistoryStore.session(id: workerChat.id))
        #expect(saved.messages.last?.text.contains("Background result") == true)
        #expect(fixture.client.requests[0].systemPrompt.contains("Scout"))
        #expect(manager.memoryRepository.loadAll().contains { $0.mateID == worker.id && $0.text.contains("Scout:") })
    }

    @Test(arguments: ["delete", "clearMate", "clearAll"])
    func deletingBackgroundHistoryCannotResurrectIt(action: String) async throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let worker = fixture.addMate(name: "Scout", brain: .onDevice)
        let chat = fixture.addChat(mateID: worker.id)
        manager.backgroundRoutineSession = chat
        manager.activeRoutineTurn = ActiveRoutineTurn(
            routineID: UUID(), mateID: worker.id, task: "Routine question", writesIntoOpenChat: false
        )
        manager.sendTranscriptToClaudeWithScreenshot(transcript: "Routine question", shouldCaptureScreen: false)
        let task = try #require(manager.currentResponseTask)
        try await fixture.client.waitForRequest()
        switch action {
        case "delete": manager.deleteChat(id: chat.id)
        case "clearMate": manager.clearChats(forMateID: worker.id)
        default: manager.clearAllChats()
        }
        fixture.client.finish(text: "Late routine answer")
        await task.value
        #expect(task.isCancelled)
        #expect(manager.backgroundRoutineSession == nil)
        #expect(manager.chatHistoryStore.session(id: chat.id) == nil)
        #expect(manager.currentChat.messages.isEmpty)
    }

    @MainActor
    private final class Fixture {
        let root: URL
        let client = SuspendedConversationClient()
        let manager: CompanionManager
        private let preferences: [String: Any]
        private let preferenceKeys = ["selectedAgentBrain", "defaultHeadlessExecutor", "chatConnectorExclusions", "rememberConversations"]

        init() throws {
            preferences = Dictionary(uniqueKeysWithValues: preferenceKeys.compactMap { key in
                UserDefaults.standard.object(forKey: key).map { (key, $0) }
            })
            root = FileManager.default.temporaryDirectory.appendingPathComponent("heymate-chat-navigation-\(UUID())")
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            manager = CompanionManager(
                memoryRepository: FileMemoryRepository(fileURL: root.appendingPathComponent("memory.json")),
                chatHistoryStore: FileChatHistoryStore(fileURL: root.appendingPathComponent("chats.json")),
                agentRunStore: FileAgentRunStore(fileURL: root.appendingPathComponent("runs.json")),
                standingOrderRepository: FileStandingOrderRepository(directoryURL: root.appendingPathComponent("orders")),
                agentUndoLedger: FileAgentUndoLedger(rootDirectoryURL: root.appendingPathComponent("undo"), recoverPreparedEntriesOnInit: false),
                mateStore: FileMateStore(fileURL: root.appendingPathComponent("mates.json")),
                routineStore: FileMateRoutineStore(fileURL: root.appendingPathComponent("routines.json")),
                conversationClient: client
            )
            manager.rememberConversationsEnabled = true
        }

        func addMate(name: String, brain: AgentBrain, exclusions: [String] = []) -> Mate {
            let mate = Mate(id: UUID(), name: name, job: "Answer test questions", pinned: false, archived: false,
                            unreadCount: 0, createdAt: Date(), updatedAt: Date(), memoryNote: "", folderPath: nil,
                            brainRawValue: brain.rawValue, connectorExclusionIDs: exclusions)
            _ = manager.mateDirectory.upsertMate(mate)
            manager.syncMatePublications()
            return mate
        }

        func addChat(mateID: UUID) -> ChatSession {
            var chat = ChatSession.empty()
            chat.mateID = mateID
            chat.messages = [ChatMessage(id: UUID(), role: .user, text: "Earlier question", createdAt: Date())]
            manager.chatHistoryStore.upsert(chat)
            return chat
        }

        func cleanUp() {
            manager.cancelInFlightChatTurn()
            client.finish(throwing: CancellationError())
            for key in preferenceKeys {
                if let value = preferences[key] { UserDefaults.standard.set(value, forKey: key) }
                else { UserDefaults.standard.removeObject(forKey: key) }
            }
            try? FileManager.default.removeItem(at: root)
        }
    }
}

@MainActor
private final class SuspendedConversationClient: ToolCallingConversationClient {
    var model = "navigation-test"
    struct Request { let systemPrompt: String; let userPrompt: String }
    var requests: [Request] = []
    var approvalRequest: (ConnectorToolCoordinator, ConnectorToolApprovalRequest)?
    var approvalDecision: Bool?
    private enum Command {
        case chunk(String), tool(AssistantToolCall), finish(String), fail(Error)
    }
    private var continuation: CheckedContinuation<Command, Never>?
    private var lastToolResult: (text: String, isError: Bool)?

    func analyzeImageStreaming(images: [(data: Data, label: String)], systemPrompt: String,
                               conversationHistory: [(userPlaceholder: String, assistantResponse: String)],
                               userPrompt: String, onTextChunk: @MainActor @Sendable (String) -> Void) async throws -> (text: String, duration: TimeInterval) {
        try await analyzeImageStreaming(images: images, systemPrompt: systemPrompt, conversationHistory: conversationHistory,
                                        userPrompt: userPrompt, availableTools: [], onTextChunk: onTextChunk,
                                        onToolCallRequested: { _ in ("No tool handler", true) })
    }

    func analyzeImageStreaming(images: [(data: Data, label: String)], systemPrompt: String,
                               conversationHistory: [(userPlaceholder: String, assistantResponse: String)], userPrompt: String,
                               availableTools: [AssistantToolDefinition], onTextChunk: @MainActor @Sendable (String) -> Void,
                               onToolCallRequested: @MainActor @Sendable (AssistantToolCall) async -> (text: String, isError: Bool)) async throws -> (text: String, duration: TimeInterval) {
        requests.append(Request(systemPrompt: systemPrompt, userPrompt: userPrompt))
        if let (coordinator, request) = approvalRequest {
            approvalDecision = await coordinator.requestApproval(for: request)
            return ("Approval test completed", 0)
        }
        // Deliberately ignores task cancellation to model a provider that
        // still emits queued callbacks and terminal events after Stop.
        while true {
            let command = await withCheckedContinuation { continuation = $0 }
            switch command {
            case .chunk(let text): onTextChunk(text)
            case .tool(let call): lastToolResult = await onToolCallRequested(call)
            case .finish(let text): return (text, 0)
            case .fail(let error): throw error
            }
        }
    }

    func waitForRequest() async throws {
        for _ in 0..<100 {
            if continuation != nil { return }
            await Task.yield()
        }
        throw NSError(domain: "ChatTurnNavigationTests.requestDidNotStart", code: 1)
    }

    func emitChunk(_ text: String) async throws {
        send(.chunk(text))
        try await waitForRequest()
    }

    func requestTool(_ call: AssistantToolCall) async throws -> (text: String, isError: Bool) {
        lastToolResult = nil
        send(.tool(call))
        try await waitForRequest()
        return try #require(lastToolResult)
    }

    func finish(text: String) { send(.finish(text)) }
    func finish(throwing error: Error) { send(.fail(error)) }

    private func send(_ command: Command) {
        let pending = continuation
        continuation = nil
        pending?.resume(returning: command)
    }
}
