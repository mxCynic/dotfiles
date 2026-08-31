hl.workspace_rule({ workspace = "10", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "8", persistent = true })
hl.workspace_rule({ workspace = "special:magic", gaps_out = 160, gaps_in = 20 })

-- 特殊工作区里窗口最大化(伪全屏)时清除间隙,不再被 gaps_out 顶出;
-- 只影响最大化状态,平时小一圈的规则仍然生效。
hl.workspace_rule({ workspace = "s[true] f[1]", gaps_out = 0, gaps_in = 0 })
