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
