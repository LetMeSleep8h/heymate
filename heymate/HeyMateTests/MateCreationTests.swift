//
//  MateCreationTests.swift
//  HeyMateTests
//

import Foundation
import Testing
@testable import HeyMate

struct MateCreationTests {

    @Test func namedTeachingMatePreservesNameRoleAndConstraints() {
        let request = MateCreationParser.parseRequests(
            "Create a test mate named Pixel QA, a patient Photopea design tutor. Explain one step then wait. Do not start a routine or coding job."
        )
        #expect(request == [MateCreationRequest(
            name: "Pixel QA",
            job: "a patient Photopea design tutor",
            soul: "Explain one step then wait. Do not start a routine or coding job."
        )])
    }

    @Test(arguments: [
        "Please create a mate called \"Pixel, QA\", a patient design tutor",
        "make me a mate named 'Pixel, QA': a patient design tutor",
        "Add a mate named “Pixel, QA”, a patient design tutor"
    ])
    func quotedNamesKeepTheirPunctuation(command: String) {
        #expect(MateCreationParser.parseRequests(command) == [MateCreationRequest(
            name: "Pixel, QA", job: "a patient design tutor"
        )])
    }

    @Test(arguments: [
        "Do not create a test mate named Pixel QA, a patient design tutor.",
        "Don't make me a mate that watches my inbox",
        "Never make me three mates: inbox, research, newsletter",
        "Please don't make me mates: inbox, research",
        "\"Create a test mate named Pixel QA, a patient design tutor.\"",
        "‘make me a mate that watches my inbox’",
        "`make me three mates: inbox, research, newsletter`",
        "An example: make me a mate that watches my inbox",
        "Explain this command: make me three mates: inbox, research, newsletter",
        "Can you create a test mate named Pixel QA, a patient design tutor?",
        "What happens if I make me mates: inbox, research?",
        "Create a mate named \"Pixel QA, a patient design tutor",
        "Create a mate named Pixel QA, "
    ])
    func nonCommandsDoNotCreateMates(text: String) {
        #expect(MateCreationParser.parseRequests(text) == nil)
    }

    @Test(arguments: [
        ". Actually, do not create it yet.",
        " but don't create it yet.",
        " actually don’t make it yet.",
        ". Don't create Pixel yet.",
        ". Don’t save the mate yet.",
        ". Never mind.",
        ", only after I confirm.",
        "; if we approve.",
        ". Wait for my confirmation before creating it.",
        ". Ask for my approval.",
        " — is that the right command?",
        ", is this a valid command?",
        ".Then create a mate named Scout, a research assistant.",
        " and create a mate named Scout, a research assistant.",
        " then add another mate called Scout, a researcher.",
        "; also make me a mate that researches competitors.",
        "\nAnd add another mate called Scout, a researcher."
    ])
    func qualifiedOrCompoundCreationIsLeftToChat(suffix: String) {
        #expect(MateCreationParser.parseRequests("Create a mate named Pixel, a design tutor" + suffix) == nil)
    }

    @Test(arguments: [
        "Do not create files or start coding jobs.",
        "Don't make it boring.",
        "Wait for my confirmation before each lesson step.",
        "Ask “What would you try?”",
        "Explain how to create a mate named Scout."
    ])
    func teachingBehaviorRemainsValid(soul: String) {
        #expect(MateCreationParser.parseRequests("Create a mate named Pixel, a design tutor. " + soul) == [
            MateCreationRequest(name: "Pixel", job: "a design tutor", soul: soul)
        ])
    }

    @Test func jobCanDescribeCreationWithoutBecomingACompoundCommand() {
        #expect(MateCreationParser.parseRequests("Create a mate named Pixel, a tutor who teaches me how to create a mate named Scout") == [
            MateCreationRequest(name: "Pixel", job: "a tutor who teaches me how to create a mate named Scout")
        ])
        #expect(MateCreationParser.parse("make me a mate that watches my inbox. Actually, do not create it yet.") == nil)
        #expect(MateCreationParser.parse("make me two mates: inbox, research, only after I confirm.") == nil)
    }

    @Test func oneMateKeepsTheJobText() {
        let jobs = MateCreationParser.parse("make me a mate that watches my inbox")
        #expect(jobs == ["watches my inbox"])
        #expect(MateCreationParser.parseRequests("make me a mate that watches my inbox") == [
            MateCreationRequest(name: nil, job: "watches my inbox")
        ])
    }

    @Test func clickyIsAnAlias() {
        let jobs = MateCreationParser.parse("make me a clicky that watches my inbox")
        #expect(jobs == ["watches my inbox"])
    }

    @Test func listParsesUpToFiveJobs() {
        let jobs = MateCreationParser.parse(
            "make me three mates: inbox, competitor research, and newsletter"
        )
        #expect(jobs == ["inbox", "competitor research", "newsletter"])

        let six = MateCreationParser.parse(
            "make me mates: one, two, three, four, five, six"
        )
        #expect(six?.count == 5)
        #expect(six?.last == "five")
    }

    @Test func ordinaryChatIsNotAMateCommand() {
        #expect(MateCreationParser.parse("what is in my inbox") == nil)
    }

    @Test func inboxWatchIsTwoWordsAndNotBuddy() {
        let name = MateNameGenerator.name(for: "watches my inbox", existingNames: [])
        #expect(name.split(separator: " ").count == 2)
        #expect(name.hasSuffix("Buddy") == false)
        #expect(name == "Inbox Scout")
    }

    @Test func generatorVariesAgainstExistingNames() {
        let name = MateNameGenerator.name(
            for: "watches my inbox",
            existingNames: ["Inbox Scout"]
        )
        #expect(name != "Inbox Scout")
        #expect(name.hasSuffix("Buddy") == false)
        #expect(name.split(separator: " ").count == 2)
    }
}

@MainActor
@Suite(.serialized)
struct MateCreationCommandTests {
    @Test(arguments: [
        "Create a mate named Pixel, a design tutor. Actually, do not create it yet.",
        "Create a mate named Pixel, a design tutor but don't create it yet.",
        "Create a mate named Pixel, a design tutor, only after I confirm.",
        "Create a mate named Pixel, a design tutor — is that the right command?",
        "Create a mate named Pixel, a design tutor.Then create a mate named Scout, a research assistant.",
        "Create a mate named Pixel, a design tutor and create a mate named Scout, a researcher."
    ])
    func qualifiedRequestsDoNotMutateRoster(text: String) throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let originalMates = manager.mates
        let originalChat = manager.currentChat

        #expect(!manager.acceptLocalMateCommand(text))

        #expect(manager.mates == originalMates)
        #expect(manager.currentChat == originalChat)
        #expect(manager.currentResponseTask == nil)
        #expect(manager.agentRuns.isEmpty)
        #expect(manager.routines.isEmpty)
    }

    @Test func namedCreationSavesAndOpensMateWithoutStartingWork() throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        let text = "Create a test mate named Pixel QA, a patient Photopea design tutor. Explain one step then wait. Do not start a routine or coding job."

        #expect(manager.acceptLocalMateCommand(text))

        let mate = try #require(manager.mates.first { $0.name == "Pixel QA" })
        #expect(mate.job == "a patient Photopea design tutor")
        #expect(mate.soul == "Explain one step then wait. Do not start a routine or coding job.")
        #expect(manager.activeMateID == mate.id)
        #expect(manager.currentChat.mateID == mate.id)
        #expect(manager.currentChat.messages.first?.text == text)
        #expect(manager.currentChat.messages.last?.text.contains("I added a mate.") == true)
        #expect(FileMateStore(fileURL: fixture.root.appendingPathComponent("mates.json")).mate(id: mate.id) == mate)
        #expect(manager.currentResponseTask == nil)
        #expect(manager.agentRuns.isEmpty)
        #expect(manager.routines.isEmpty)
    }

    @Test func duplicateExplicitNameIsHandledWithoutRenamingOrStartingWork() throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        let manager = fixture.manager
        #expect(manager.acceptLocalMateCommand("Create a mate named Pixel QA, a patient design tutor"))
        let original = try #require(manager.mates.first { $0.name == "Pixel QA" })
        let originalCount = manager.mates.count

        #expect(manager.acceptLocalMateCommand("Create a mate named pixel qa, an entirely different tutor"))

        #expect(manager.mates.count == originalCount)
        #expect(manager.mates.first { $0.id == original.id } == original)
        #expect(manager.currentChat.messages.last?.text.contains("already exists") == true)
        #expect(manager.currentResponseTask == nil)
        #expect(manager.agentRuns.isEmpty)
    }

    @Test func legacyCreationStillGeneratesAName() throws {
        let fixture = try Fixture()
        defer { fixture.cleanUp() }
        #expect(fixture.manager.acceptLocalMateCommand("make me a mate that watches my inbox"))
        let mate = try #require(fixture.manager.mates.first { $0.name == "Inbox Scout" })
        #expect(mate.job == "watches my inbox")
        #expect(mate.soul.isEmpty)
        #expect(fixture.manager.activeMateID == mate.id)
        #expect(fixture.manager.currentResponseTask == nil)
    }

    @MainActor
    private final class Fixture {
        let root: URL
        let manager: CompanionManager
        private let preferences: [String: Any]
        private let preferenceKeys = ["selectedAgentBrain", "defaultHeadlessExecutor", "chatConnectorExclusions", "rememberConversations"]

        init() throws {
            preferences = Dictionary(uniqueKeysWithValues: preferenceKeys.compactMap { key in
                UserDefaults.standard.object(forKey: key).map { (key, $0) }
            })
            root = FileManager.default.temporaryDirectory.appendingPathComponent("heymate-mate-creation-\(UUID())")
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            manager = CompanionManager(
                memoryRepository: FileMemoryRepository(fileURL: root.appendingPathComponent("memory.json")),
                chatHistoryStore: FileChatHistoryStore(fileURL: root.appendingPathComponent("chats.json")),
                agentRunStore: FileAgentRunStore(fileURL: root.appendingPathComponent("runs.json")),
                standingOrderRepository: FileStandingOrderRepository(directoryURL: root.appendingPathComponent("orders")),
                agentUndoLedger: FileAgentUndoLedger(rootDirectoryURL: root.appendingPathComponent("undo"), recoverPreparedEntriesOnInit: false),
                mateStore: FileMateStore(fileURL: root.appendingPathComponent("mates.json")),
                routineStore: FileMateRoutineStore(fileURL: root.appendingPathComponent("routines.json"))
            )
        }

        func cleanUp() {
            manager.cancelInFlightChatTurn()
            for key in preferenceKeys {
                if let value = preferences[key] { UserDefaults.standard.set(value, forKey: key) }
                else { UserDefaults.standard.removeObject(forKey: key) }
            }
            try? FileManager.default.removeItem(at: root)
        }
    }
}
