---
name: remove-ai-writing
description: Scan academic writing (LaTeX or plain text) for AI-generated patterns — redundant recaps, mechanical transitions, hollow connectives — and remove them surgically. Designed for Chinese-language academic theses but applies broadly.
---

# 去除論文寫作 AI 味 Skill

## When to Use

Trigger when user:
- Says "AI 味太重"、"去 AI 味"、"太像 AI 寫的"
- Asks to make writing sound more natural or academic
- Wants to clean up thesis / report prose
- Uses phrases like "remove AI writing patterns", "make it sound human"

---

## What "AI 味" Looks Like

AI-generated academic prose fails in predictable ways. Every pattern below shares the same root cause: **the model pads content by repeating information rather than advancing it**.

### Pattern 1 — 三段式重複（Triple Recap）
The same conclusion appears three times: once at the start of a section ("本節將說明…"), once in the body, and once at the end ("綜合以上，本研究發現…"). Each instance is nearly identical.

**Fix**: Keep the body instance. Delete the preview and the recap.

### Pattern 2 — 無效「換言之」
"換言之" / "亦即" / "也就是說" followed by a sentence that adds zero new information — it only restates the prior sentence in slightly different words.

**Fix**: Delete the entire "換言之…" sentence. If it genuinely introduces a new framing, rewrite without the connective.

### Pattern 3 — 空洞呼應詞
Phrases like "相互呼應"、"彼此印證"、"遙相呼應" describe a relationship without specifying what it is. They read as filler.

**Fix**: Replace with a precise verb: 一致、吻合、支持、驗證。If even that is too vague, state the specific agreement (e.g., "兩者皆指向 fill depth 為主要解釋變數").

### Pattern 4 — 段首回顧（Section-Opening Recap）
A section opens by summarizing the previous section ("前一章已說明…本節將進一步…"). The reader just read the previous section; they don't need a summary.

**Fix**: Delete the recap. Open directly with the first substantive claim.

### Pattern 5 — 機械式段尾前瞻（Formulaic Forward References）
Every section ends with "第 X 章將進一步…" / "下一節將說明…" as a template. Occasional forward references are fine; appearing at every section boundary is formulaic.

**Fix**: Delete forward references that are purely positional (i.e., they only say "the next chapter covers the next chapter's topic"). Keep them only when they create a genuine logical bridge.

### Pattern 6 — 結論重複 Results（Conclusion = Results Summary）
The conclusion chapter reproduces the results chapter findings almost verbatim. A conclusion should synthesize, explain implications, and identify limitations — not retell.

**Fix**: Compress results recap to 1–2 sentences. Shift focus to "so what": practical implications, limitations, future work.

### Pattern 7 — 過度強調詞堆疊
Phrases like "充分說明"、"充分體現"、"充分驗證" appear repeatedly. Each use weakens the ones before it.

**Fix**: Delete the adverb. "說明"、"體現"、"驗證" carry the meaning alone.

---

## Scanning Procedure

When asked to scan a file or passage:

1. **Read the full text** first — do not edit during the first pass.
2. **Identify each instance** by pattern type and line number. List them.
3. **Classify severity**:
   - 🔴 Delete: no information lost by removing
   - 🟡 Rewrite: the idea is worth keeping but the phrasing must change
   - 🟢 Keep: unusual usage that actually adds value
4. **Report the list** to the user before making any changes.
5. **Apply changes** surgically: prefer deletion over rewriting. Do not introduce new sentences.
6. **Verify** that surrounding sentences still connect correctly after deletion.

---

## Editing Principles

- **Delete, don't rewrite** — replacing one AI sentence with another AI sentence gains nothing. If a sentence is redundant, remove it.
- **Surgical, not structural** — do not reorganize paragraphs or add new content. Only remove or minimally rephrase.
- **One pass per file** — scan the whole file, list all issues, then apply all edits. Do not loop back and invent new issues.
- **Preserve technical content** — never delete or simplify quantitative claims, model equations, or citations.
- **LaTeX safety** — when editing `.tex` files, do not touch `\begin`, `\end`, `\label`, `\ref`, `\cite`, `\footnote`, or equation environments. Only edit prose in paragraph blocks.

---

## Example

**Before (AI味)**:
```
本節將說明 local level model 之選擇依據。研究結果顯示，local level model 在 AIC 與測試集誤差上優於其他模型。換言之，local level model 的表現較其他模型更佳。由此可見，local level model 是較合適的選擇。綜合以上，本研究選擇 local level model 作為主要模型，相關結果將於下一節詳細說明。
```

**After**:
```
Local level model 在 AIC 與測試集誤差上優於其他候選模型，故作為主要模型。
```

Three sentences became one. All deleted content was redundant.
