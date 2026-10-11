# Product polish verification — 11 October 2026

The app and test targets built successfully. The final focused run passed **141 tests in 16 suites**. `git diff --check` passed.

## Covered behavior

- A new mate retains its name and job without a custom personality. First Mate and specialists receive their own saved note.
- On-device prompts preserve bounded name, job, personality, and memory fields even when individual fields are long or the context budget shrinks. Capability rules remain present.
- Teaching requests stay in the guided chat flow; execution requests retain the existing plan approval flow.
- Summary persistence replaces only the originating mate's summary. Shared preferences/project facts remain shared. Legacy summaries decode without losing data and are excluded from replies when no owner is known.
- Navigation rejects late chunks, stale successes, tool calls, and errors, including providers that ignore cancellation. Background routines retain their chat and selected brain; deleting their history prevents later delivery from recreating it.
- Approval cancellation cannot clear a newer request. Guided walkthrough parsing, state transitions, and privacy invariants also pass.

The new reply attribution and memory-scope labels compiled successfully. Visual inspection and live model evaluation of the new build remain separate release checks; these unit tests do not establish either.

## Commands

Run from the repository root. The scratch DerivedData path avoids rebuilding or signing the installed app.

```sh
xcodebuild \
  -project heymate/HeyMate.xcodeproj \
  -scheme HeyMate \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER= \
  build-for-testing

xcodebuild \
  -project heymate/HeyMate.xcodeproj \
  -scheme HeyMate \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  -only-testing:HeyMateTests/MateProfileTests \
  -only-testing:HeyMateTests/OnDevicePromptFitTests \
  -only-testing:HeyMateTests/FirstMateTests \
  -only-testing:HeyMateTests/MateAgentBriefTests \
  -only-testing:HeyMateTests/BehaviorContractTests \
  -only-testing:HeyMateTests/GuidedReplyParserTests \
  -only-testing:HeyMateTests/GuidedWalkthroughTests \
  -only-testing:HeyMateTests/MateWorkGateTests \
  -only-testing:HeyMateTests/MemoryRepositoryTests \
  -only-testing:HeyMateTests/MemoryAndSkillsPromptTests \
  -only-testing:HeyMateTests/PrivacyInvariantsTests \
  -only-testing:HeyMateTests/ChatTurnNavigationTests \
  -only-testing:HeyMateTests/ConnectorApprovalPolicyTests \
  -only-testing:HeyMateTests/ComputerUseActionTests \
  -only-testing:HeyMateTests/ComputerUseTagParserTests \
  -only-testing:HeyMateTests/CompanionStateMachineTests \
  test-without-building
```

## Local evidence

- Build log: `/tmp/heymate-product-polish-build.log`
- Test log: `/tmp/heymate-product-polish-tests.log`
- Result bundle: `/tmp/heymate-product-polish-derived/Logs/Test/Test-HeyMate-2026.10.11_11-51-31-+0800.xcresult`
- Final test result: `141 tests in 16 suites passed after 0.174 seconds.`

The repository's existing Apple framework, deprecation, and actor-isolation warnings remain. The new default-budget isolation warning found during this work was fixed before the final run.

The full suite was not rerun here. Open PR #14 separately fixes the known headless CLI EOF spin that can hang the full suite on current main; its files were left untouched.

## Follow-up: direct named mate creation

Live testing of installed version 1.0.38 found that `Create a test mate named Pixel QA, a patient Photopea design tutor. Explain one step then wait. Do not start a routine or coding job.` took an approved Codex work job of roughly two minutes. Pixel QA was ultimately persisted with the requested name and instructions in its job field, but no personality. This was an unnecessarily expensive route for a local roster change; creation was not impossible.

The follow-up recognizes a narrow, explicit named-creation grammar before a model turn. It saves the requested name, puts the role in the job and subsequent instructions in the personality, and opens the new mate. Existing immediate-save behavior is preserved. A duplicate explicit name receives local feedback instead of being silently renamed. Quoted examples, leading negations, questions, and embedded examples do not match the creation parser. Existing `make me a mate that …` and list commands remain supported.

The app and test targets built successfully again. **62 tests in 8 suites passed**, followed by **3 routine-phrase tests in 1 suite**. Manager integration checks verify the exact live request persists and opens the mate without starting a response task, agent run, or routine; duplicate names and legacy creation are also covered. No installed app was replaced or signed by these checks. Live evaluation of this new build remains a separate release check.

```sh
xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate -configuration Debug \
  -destination 'platform=macOS' -derivedDataPath /tmp/heymate-product-polish-derived \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER= \
  build-for-testing

xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  -only-testing:HeyMateTests/MateCreationTests \
  -only-testing:HeyMateTests/MateCreationCommandTests \
  -only-testing:HeyMateTests/ChatTurnNavigationTests \
  -only-testing:HeyMateTests/MateProfileTests \
  -only-testing:HeyMateTests/FirstMateTests \
  -only-testing:HeyMateTests/OnDevicePromptFitTests \
  -only-testing:HeyMateTests/MateAgentBriefTests \
  -only-testing:HeyMateTests/MateStoreTests \
  test-without-building

xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  -only-testing:HeyMateTests/MateRoutinePhraseTests \
  test-without-building
```

The first focused command originally also contained `-only-testing:HeyMateTests/MateRoutineTests`, which is a filename rather than a suite. The separate run above used the correct suite name; the reported 62 tests do not include those 3 tests.

- Build log: `/tmp/heymate-mate-creation-build.log`
- Focused test log: `/tmp/heymate-mate-creation-tests.log`
- Focused result: `/tmp/heymate-product-polish-derived/Logs/Test/Test-HeyMate-2026.10.11_12-05-00-+0800.xcresult`
- Routine test log: `/tmp/heymate-mate-creation-routine-tests.log`
- Routine result: `/tmp/heymate-product-polish-derived/Logs/Test/Test-HeyMate-2026.10.11_12-05-28-+0800.xcresult`

### Review follow-up

Review found that trailing request qualifiers could be stored as personality and a second creation command could be swallowed into the first mate's description. Conservative clause guards now leave cancellations, confirmation conditions, command questions, and compound roster commands to ordinary chat without local mutation. This includes punctuation-free `but don't create it yet` and `and create a mate named Scout` forms. Behavior instructions such as avoiding file creation, waiting for confirmation before each lesson step, asking a question, or teaching how to create a mate remain valid. These are bounded grammar guards, not general natural-language intent classification.

The reviewer rechecked the failing cases and valid counterexamples with no remaining finding in the scoped change. The app/test build passed again; **16 tests in 2 suites passed** in the final focused run:

```sh
xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  -only-testing:HeyMateTests/MateCreationTests \
  -only-testing:HeyMateTests/MateCreationCommandTests \
  test-without-building
```

- Final build log: `/tmp/heymate-mate-creation-review-build.log`
- Final test log: `/tmp/heymate-mate-creation-review-tests.log`
- Final result: `/tmp/heymate-product-polish-derived/Logs/Test/Test-HeyMate-2026.10.11_12-13-16-+0800.xcresult`
