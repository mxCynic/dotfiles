---
name: system-security-health
description: Diagnose recent Linux desktop/system health, security-relevant warnings, crashes, and user-session bugs by running `mxbin/log-health` and interpreting its report. Use when the user asks to check system security, inspect recent bugs/errors/crashes, review logs, investigate instability, or produce a report with likely causes and possible fixes.
---

# System Security Health

## Overview

Use this skill to produce an evidence-based report from the local `mxbin/log-health` collector. Focus on recent bugs, security-relevant signals, likely causes, and practical next steps.

## Workflow

1. Run the collector from the dotfiles repo:

   ```sh
   mxbin/log-health
   ```

   If the user gives a time window, pass it as the first argument, for example:

   ```sh
   mxbin/log-health "24 hours ago"
   mxbin/log-health "14 days ago"
   ```

2. Capture the generated report path from the command output, usually `Wrote /tmp/log-health-YYYYMMDD-HHMMSS.md`.
3. Read the generated markdown report. Prefer targeted reads/searches over pasting the whole file into context if it is large.
4. If the report says system-level follow-up needs privileged commands, do not run `sudo` unless the user explicitly asks and approval is available. Mention that kernel, hardware, disk, thermal, GPU reset, and OOM evidence may be incomplete without those commands.
5. Correlate recurring errors across sections before drawing conclusions. Treat repeated crashes, coredumps, portal failures, audio/Bluetooth timeouts, Hyprland warnings, and application-specific failures as stronger evidence than isolated one-off messages.
6. Produce a concise report in Chinese unless the user requested another language.

## Analysis Guidance

Classify findings by confidence:

- High confidence: repeated errors with timestamps, matching coredumps, failed units, or the same component appearing in multiple sections.
- Medium confidence: one component repeatedly warns or times out, but without a direct crash or failed service.
- Low confidence: isolated warnings, noisy application logs, or messages without clear user-visible impact.

Prioritize security-relevant and stability-relevant signals:

- Authentication, permission, sandbox, portal, secret/keyring, SSH, browser, and package/update failures.
- Kernel, GPU, filesystem, disk, memory/OOM, thermal, watchdog, and hardware reset messages when available.
- User-session crashes and coredumps, especially repeated crashes of shell, compositor, portal, notification, audio, browser, editor, or game/platform processes.
- Services that fail to start, restart in loops, time out, or lose IPC/DBus connections.

Avoid overstating causality. Say "可能原因" when inferring from logs, and separate confirmed facts from hypotheses.

## Report Format

Use this structure:

```markdown
**检查范围**
- 日志窗口：
- 报告文件：
- 权限限制：

**近期主要问题**
1. 问题标题
   - 证据：
   - 影响：
   - 可能原因：
   - 可能解决方案：
   - 置信度：

**安全相关信号**
- 没有明显安全异常，或列出具体异常和建议。

**建议优先级**
1. 先处理会导致崩溃、数据风险或安全风险的问题。
2. 再处理重复警告、体验问题和低风险噪声。
```

Keep the report actionable. Include exact commands only when they are the next useful diagnostic or repair step, and explain whether they are safe read-only diagnostics or state-changing fixes.
