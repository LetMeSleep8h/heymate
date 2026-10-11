# Product polish verification — 11 October 2026

## Current result

The combined app, embedded runner, and test targets built successfully with ad-hoc signing. The complete HeyMateTests target passed **1,114 tests in 167 suites**, in **28.368 seconds**. `git diff --check` passed. Independent reviews of creation, consent, response ownership, and private-result delivery found no remaining blocker after the fixes described below.

This local result includes the original EOF fix from PR #14 and all current PR #20 polish. The original #14 commit is being integrated into the branch, rather than reauthoring its patch. Final-head CI is a separate check.

**Native acceptance is still pending.** The Mac reports `IOConsoleLocked = Yes`; native accessibility returns no windows and screen capture is blank. Automated tests and a successful app launch do not establish a successful live provider conversation, a completed Photopea walkthrough, or fresh-install behavior. PR #20 must remain draft and unmerged until the patched-app checks below pass.

## Behavior covered

- Each mate receives its own name, job, personality, saved note, and owned summaries. Bounded on-device prompts retain identity and capability rules. Shared preferences/project facts remain shared; legacy ownerless summaries remain stored but are excluded from replies.
- Explicit named creation happens locally, preserves instructions, handles duplicate names, and conservatively rejects cancelled, qualified, and compound creation commands. Creating a mate shows a distinct local greeting and one editable starter without sending a model request, activating connectors, creating a workspace, or starting a job. Starter use/dismissal persists across reopening; legacy chats still decode.
- Teaching stays in chat. Foreground responses and intent classification retain their originating conversation/provider and reject stale callbacks after navigation, cancellation, or replacement. Background routines and handoffs retain their own chat; late completion does not recreate deleted history or ignore disabled history.
- Pending approvals remain request-scoped. Navigation preserves unrelated running jobs, approvals, and voice input. Changing provider/model during a voice classification releases only that request's finished-input state and preserves newer recordings.
- OpenCode consent follows the receiving mate, model, explicit executor choice, and conversation. Confirmation revalidates its target and resumes the original route. Explicit background agent commands use the receiving mate's provider; classifier rewrites preserve explicit executor choices. Both job launch boundaries refuse an unapproved OpenCode switch before a CLI call.
- Successful jobs retain their full private answer, up to 32 KiB with an explicit truncation notice, and deliver it to the initiating chat. Missing results are reported as unverified rather than generic success. Failed, blocked, cancelled, and handed-off runs have distinct outcomes.
- Private final answers use attempt-scoped, atomically durable files with restrictive permissions and guarded reads. Credentials/local absolute paths are redacted; normal source URLs remain useful. Portable receipts and runner journals exclude private answer prose. Journal-before-state recovery, ordinary replay deduplication, follow-ups, and localhost preview resolution are covered. Chat/store writes are not a single cross-file transaction; these tests do not claim crash-atomic exactly-once delivery.

## Failures found and fixed

1. The first combined run exposed the existing CLI EOF spin. The exact original PR #14 patch passed its EOF/runner diagnosis: **12 tests in 3 suites**, 8.829 seconds.
2. Complete runs still timed out in short runner fixtures. The failure reproduced after manager-heavy suites. A process/stack sample showed approximately 60 real OpenCode/npm/node children and ten cooperative threads blocked in automatic CLI readiness probes. This was not resolved merely by removing speech-model warmup.
3. The test host now skips automatic readiness probes and selects system voice providers only when actual XCTest hosting is detected. Explicit readiness-probe APIs/tests remain available. A scratch QA app using only `HEYMATE_TEST_DATA_ROOT` keeps normal services. The original preference snapshot and exit restoration remain. No runtime or test timeout was increased.
4. Review found and fixed explicit-agent provider misrouting, missing executor-override consent, and a stuck foreground voice state after model changes. Targeted regressions are included in the final complete run.

The successful runner fixture completed in 0.114 seconds in the final run; all five terminal-result scenarios completed in 0.371 seconds. Existing framework/deprecation warnings remain; no build error remained.

## Reproduce

Run from the repository root:

```sh
xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER= \
  build-for-testing

xcodebuild \
  -project heymate/HeyMate.xcodeproj -scheme HeyMate \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/heymate-product-polish-derived \
  -only-testing:HeyMateTests \
  test-without-building
```

Local evidence:

- Build: `/tmp/heymate-polish-final-isolation-build.log`
- Complete tests: `/tmp/heymate-polish-final-isolation-full-tests.log`
- Result bundle: `/tmp/heymate-product-polish-derived/Logs/Test/Test-HeyMate-2026.10.11_13-27-37-+0800.xcresult`
- EOF diagnosis: `/tmp/heymate-polish-pr14-diagnostic-tests.log`
- Order-dependent failure diagnosis: `/tmp/heymate-engine-manager-sample.txt` and `/tmp/heymate-engine-manager-processes.txt` (private local diagnostics, not release assets)

Earlier overlapping checks passed 141 tests/16 suites for identity/memory/navigation, 62/8 plus 3 routine tests for named creation, 16/2 after parser review, and 39/5 after navigation-state review. [CI at `5ab9a49`](https://github.com/UmarSiddiqui/heymate/actions/runs/38111416968) passed 1,064 tests/162 suites before the additional polish. These are historical, overlapping checks, not counts to add to the final 1,114.

## Live findings and remaining gate

Installed version 1.0.38 routed a direct request to create Pixel QA through an approved coding job taking roughly two minutes. Its resulting mate retained the name, but not a separate personality. A later identity reply used Pixel QA correctly; a saved note about a purple-triangle practice logo was missed and unrelated Photopea history appeared. Those observations motivated the creation/memory fixes; they are not tests of the patched build.

An earlier isolated QA copy launched, but native accessibility timed out. In this validation turn, the original installed app, data, and preferences were backed up before staging Debug `5ab9a49` at the normal app path. Startup services ran; both HeyMate and Chrome subsequently had no native windows while the console was locked. No successful live conversation was verified in either patched copy. The original app must be restored if validation ends while blocked.

Before merging:

1. Test two named mates, their distinct greetings, and separate saved notes with an actual provider.
2. Switch conversations during a reply and classification; confirm no late output or work in the destination, while unrelated approval/input remains intact.
3. Run a bounded job, switch chats, verify its useful answer returns to the original chat, then relaunch and verify persistence/recovery.
4. Complete a real Photopea lesson: open the owned opaque sample PNG, follow HeyMate's guidance to remove white background, export PNG, and verify transparent corners and preserved artwork.
5. Confirm final-head CI, then merge using a merge commit so the original #14 commit remains in history.

The real Photopea recording is not yet available. A five-second native capture proved recording works but showed the wrong browser tab; it is private diagnostic footage. The earlier illustrated concept video is not a substitute for a real walkthrough.
