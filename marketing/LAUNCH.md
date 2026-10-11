# HeyMate launch kit

Working launch plan, updated 11 October 2026. Copy below is a draft; it is not a record of publication. Release notes belong to a released build, not an unmerged PR.

## Lead with a useful task

**Positioning:** Learn your Mac, one step at a time.

**One sentence:** HeyMate is a free, open-source Mac companion that explains the next step, points to it, and waits while you learn the app in front of you.

**First audience:** Mac users learning a creative or everyday app. Start with one observable result, such as removing a background from a sample logo in Photopea. Coding agents and notch utilities can support the story after the main benefit is clear.

**Promise to prove:** A person can finish the task and repeat it without asking again. Treat this as a product goal until real tests establish it. Do not claim superiority over HeyClicky, OpenClicky, ChatGPT, or every notch app from a feature checklist.

Keep private analytics evidence separate from public launch copy. Treat the checks below as proposed gates until a current test records their results.

## Before a broad launch

1. Test installation and first-run permissions on a fresh Mac account. Current builds are self-signed and not notarized; document that friction clearly. A terminal installer is not notarization.
2. Record a complete real walkthrough, including waiting time, mistakes, corrections, and successful export. Use an owned sample image and remove private account details.
3. Verify two named mates behave differently, retain the right context, and remain distinct after switching chats and relaunching. Do not advertise a polished persona experience from configuration fields alone.
4. Resolve the current release-blocking bugs and review overlapping PRs. On 11 October the only open PR was [#14: detach CLI pipe readers at EOF](https://github.com/UmarSiddiqui/heymate/pull/14); recheck before editing related code.
5. Invite ten people to try the same small task. Record where they fail, whether they finish, and whether they use HeyMate again. Fix repeated blockers before paying for reach or making a large announcement.

Suggested pilot gates, not measured results: at least 8 of 10 complete the chosen task without live rescue; at least 5 use HeyMate again within seven days; no unhandled crash, cross-mate identity leak, or private content in telemetry. The small sample gives feedback, not statistical proof.

## Proof video

Use the existing Remotion project for captions and framing. The current 38-second film is a recreated UI animation; label it as an illustrated tour. Do not present it as a screen recording.

New capture brief:

- **0–4 s:** Show the starting logo and the exact request: “Walk me through removing this background, one step at a time.”
- **4–18 s:** Real app points to the first control. The person clicks it. Preserve enough waiting time to show the actual interaction; label any speed-up.
- **18–32 s:** Show a fresh step after the screen changes, and a correction if one was needed.
- **32–42 s:** Show the exported transparent image. Briefly repeat the important action without the assistant.
- **42–50 s:** Name the app, show version/provider used, and link to the demo and source. Note current install limitations in the description.

Produce a readable 16:9 walkthrough and a separately framed 9:16 cut; do not crop away the highlighted target. Add captions for every spoken instruction. Use only audio and assets with redistribution rights. Keep the original capture and an edit list. Publication requires a completed capture; animations must remain labeled.

## Draft X posts

Post one is under 280 characters without an attachment URL:

> Learning an app should leave you with a skill. HeyMate points to the next step, explains it out loud, and waits while you try it. Free, open source, and built for Mac. I'm looking for people to test one useful walkthrough: https://getheymate.vercel.app

Follow-up after real task verification:

> Try it with a small task in the app you're learning. Hold Control + Option and ask “Walk me through this, one step at a time.” It uses your Claude or ChatGPT plan through the official CLI. Provider limits apply; screen guidance needs a vision-capable model.

Contributor invitation:

> Want to help build HeyMate? Small contributions welcome: better walkthrough prompts, accessible website controls, or one reproducible app tutorial. Swift isn't required for all of them. Start here: https://github.com/UmarSiddiqui/heymate/blob/main/CONTRIBUTING.md

Use one clear action per post. Do not ask viewers simultaneously to install, star, follow, join a chat, and submit a PR. Attach a real clip when one passes the capture checks above. Recheck existing posts before publishing duplicates.

## Draft creator outreach

Send only to creators whose content includes Mac apps or learning creative software. Personalize using a specific relevant video after reviewing it; do not send a bulk template.

> I build HeyMate, a free, open-source Mac companion for learning an app step by step. I'm testing a short Photopea walkthrough with a sample logo. Would you be interested in trying that task and sharing what fails? I can send the exact sample, build, setup notes, and an uncut recording. There is no requirement for a positive review. Source and download: https://github.com/UmarSiddiqui/heymate

Do not claim the recording is ready until it exists. Offer a reproducible task and honest limitations, not “better than every competitor.” Disclose any compensation or provided benefit if that changes.

## Distribution sequence

1. **Pilot:** Recruit ten testers from existing contacts and relevant Mac or creative communities where self-promotion is allowed. Use the same task and feedback form, then run one revision.
2. **Public proof:** Publish the verified clip natively on X and one video channel; link to a landing page whose first screen matches the task. Use a distinct campaign URL for each channel.
3. **Community:** Share the build in one relevant community, answer questions, and fix reported blockers. Check that community's current rules before posting. Existing notes report a Show HN account restriction; do not work around it.
4. **Creators:** Approach a small relevant group with the task, uncut evidence, current build, and known limitations. Follow up only when there is useful new evidence.
5. **Contributors:** Turn repeat failures into bounded issues with reproduction steps and acceptance checks. Review small PRs promptly. Give credit in actual release notes.
6. **Broader launch:** Consider a larger directory or Product Hunt launch after the pilot supports the promise. A calendar date alone is not readiness.

## What to measure

Website: visits by campaign, demo play, download clicks, contribution-link clicks. These are interest signals, not successful installs.

App pilot: install success, first provider connection, first completed walkthrough, wrong-step/correction rate, time to the first useful result, second use within seven days, and successful repeat without help. Use voluntary tester reports first. Any new automatic collection needs visible controls, minimal fields, and tested redaction.

GitHub: qualified visitors, opened issues with reproductions, first PRs, review turnaround, and returning contributors. Stars are a useful result of value and reach; they are not the activation metric.

## Existing distribution notes to recheck

Earlier notes in this repository reported an X thread, a Boring Notch reply, Search Console setup, GitHub social preview, an awesome-mac listing, an open-source-mac-os-apps submission, a LinkedIn composer draft, and a Show HN restriction. These have not been reverified in this source audit. Inspect the relevant account before reusing, claiming completion, or posting again.

## Links and assets

- Site: https://getheymate.vercel.app
- Repository: https://github.com/UmarSiddiqui/heymate
- Download: https://github.com/UmarSiddiqui/heymate/releases/latest/download/HeyMate.dmg
- Contribute: https://github.com/UmarSiddiqui/heymate/blob/main/CONTRIBUTING.md
- Existing motion source: `marketing/demo-video/`

The existing film uses **Show Me by Peyruis**, [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/). If using that track, preserve the full attribution from `marketing/demo-video/README.md` in every published description.
