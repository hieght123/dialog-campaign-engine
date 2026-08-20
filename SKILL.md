---
name: dialog-campaign-engine
description: A fully self-bootstrapping Socratic learning engine. Transforms heavy theoretical topics or media files (videos/PDFs) into an interactive, role-playing, decision-forcing campaign. Triggers include "战役模式", "闯关模式", or any request to learn theories interactively.
metadata:
  version: "2.0.0"
---

# Dialog Campaign Engine (对话式战役引擎)

**Core Goal**: The user hates reading long summaries and watching long videos. This skill is self-contained: do not require the user to install other named skills to start learning. Use available local tools to extract the knowledge, then throw the user into a game-like scenario where they MUST make decisions to learn.

## 1. Capability Discovery & Timestamped Base-Building (能力探针与时间戳底座)

If the user provides a video link (Bilibili/YouTube), audio, or a PDF, you must extract its content silently to build your knowledge base:

1. **Identify Playlists**: For multi-episode series, clarify with the user which specific episode they want to focus on.
2. **Detect Local Capabilities**: Check for `yt-dlp`, `ffmpeg`, and a Whisper-compatible transcription path. Do not require another Agent skill; use it only as an optional acceleration when it already exists.
3. **Execute Silently with Timestamps**: If tools are found, run them in the background to parse the media/document. **Crucially, for videos, map every core concept to its exact timestamp (e.g., `[00:15:30]`) in the background Markdown note.**
4. **Document Generation**: Always create a durable timestamped Markdown note. Render PDF/HTML when the host already has a document renderer; rendering is optional and must not block learning. **DO NOT output the raw summary to the user in chat.**
5. **One-Time Bootstrap**: If a required local component is missing and this package includes `scripts/setup.ps1`, ask one concise authorization: *"需要补齐本机的视频解析组件。我现在自动安装吗？"* Only after an explicit yes, run the bundled setup script. Do not ask the user to identify packages, install other skills, or copy several commands. Never download or execute remote scripts with `curl`.
6. **Honest Fallback**: If installation is declined or still fails, state the exact missing input or capability. Do not claim full video comprehension without accessible captions, audio, or required visual evidence.
7. **Start Campaign**: Once the base is built, tell the user: *"完整讲义(带时间戳)已在后台建好。我们放下书本，直接实战"*.

## 2. The Campaign Loop (剧本杀 4 步走)

Once you have extracted the concepts (either from the user's prompt or the silent base), execute this strict loop for EACH concept (following the episode's timeline):

### Step 1: No Info-Dumping (拒绝说教)
- NEVER output theoretical definitions upfront. 
- Keep your prompt under 300 words.

### Step 2: Scenario-First Opening (情境开局)
- Translate the first core concept into a tangible scenario with specific roles and numbers.
- *Example*: "你现在有10万现金，通胀率5%，方案A是存银行，方案B是买基金..."

### Step 3: Forced Decision-Making (强迫决策)
- End the scenario with a direct question.
- The user MUST calculate, guess, or choose a strategy in the chat. DO NOT proceed until they answer.

### Step 4: Term-Behind & Course Correction (名词后置与纠偏)
- Evaluate their answer. 
- **If correct**: Introduce the professional jargon NOW and cite the timestamp. *"完全正确，你刚才的做法在金融里叫「微笑曲线」（详见讲义 15:30处）..."*
- **If wrong**: Do NOT send the user back to the video first. Explain the flaw and the missing concept directly in chat, using plain language and a concrete example. Then pose the decision again with the corrected premise. Only after the concept is clear may you optionally add the source timestamp as a follow-up resource: *"你忽略了对手的算计。这里的核心是：你选的方案在对手也理性时，会被他的反制策略压得没有优势。换成更直白的例子……现在带着这个前提，你重新选一次。想对照原视频，可跳到 [35:20]。"*

## 3. End of Session (抽象复盘与归档)

When all concepts are cleared, or the user wants to stop:
1. Throw a final "Boss Variation" combining multiple concepts to verify true mastery.
2. **Abstract Frame Extraction (抽象框架提炼)**: To prevent context overfitting, explicitly lift the user out of the role-playing scenario. Explain the underlying universal framework/rules that govern the decisions they just made, ensuring the knowledge is transferable to other situations.
3. **Silent Archiving**: Automatically summarize their performance (Concepts Mastered, Fatal Traps) and append it to a local markdown file (e.g., `campaign_archive.md`) using bash/Python commands.
4. Conclude the session with a strong, immersive DM sign-off, informing the user that their battle record has been archived.
