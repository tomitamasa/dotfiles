# ghq + fzf integration (Ctrl+G)
ghq_fzf_repo() {
  local selected=$(ghq list -p | fzf --query "$LBUFFER" --select-1 --exit-0)
  if [[ -n "$selected" ]]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq_fzf_repo
bindkey '^g' ghq_fzf_repo

# ─────────────────────────────────────────────────────────────────────────────
# Claude Code: 複数リポジトリ × 複数セッションのナビゲーション
#
# Ctrl+G (ghq + fzf) と同じ作法で、repo / worktree / セッションを選ぶ。
# `cc` は /usr/bin/cc (C コンパイラ) と衝突するため使わない。
# ─────────────────────────────────────────────────────────────────────────────

# ccd [プロンプト...] — ghq + fzf で repo を選び、そこに cd して claude を起動
#   例: ccd            リポジトリを選んで対話開始
#       ccd "テストを直して"
ccd() {
  local selected
  selected=$(ghq list -p | fzf --prompt='claude repo> ' --select-1 --exit-0) || return
  [[ -n "$selected" ]] || return
  cd "$selected" || return
  claude "$@"
}

# ccw [worktree名] [プロンプト...] — 隔離された worktree セッションを開始
#   worktree は .claude/worktrees/<名前>/ に worktree-<名前> ブランチで作られる。
#   名前を省略すると Claude が命名する (bright-running-fox 等)。
#   終了時に中身がクリーンなら worktree ごと自動で片付く。
#   例: ccw fix-login
#       ccw "#1234"      PR から worktree を作る (クォート必須)
ccw() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ccw: git リポジトリの中で実行してください (repo を選ぶなら ccd)" >&2
    return 1
  fi
  claude --worktree "$@"
}

# cwt — この repo の worktree を fzf で選んで cd する
#   Claude が作ったもの (.claude/worktrees/) も git worktree add したものも出る。
cwt() {
  local list selected
  list=$(git worktree list 2>/dev/null) || {
    echo "cwt: git リポジトリの中で実行してください" >&2
    return 1
  }
  selected=$(printf '%s\n' "$list" | fzf --prompt='worktree> ' --select-1 --exit-0) || return
  [[ -n "$selected" ]] || return
  cd "${selected%% *}" || return
}

# cca — Agent View。バックグラウンドセッションを1画面で監視する
#   Ctrl+S でグルーピングを 状態別 ↔ ディレクトリ別 に切替 (複数 repo を見るとき用)
alias cca='claude agents'

# ccr — セッションを選んで再開 (Ctrl+W=repo の全 worktree / Ctrl+A=全プロジェクト)
alias ccr='claude --resume'

# ccb <プロンプト> — バックグラウンドに投げて即プロンプトに戻る
#   投げた先は cca で見る。並列数だけレート制限を食う点に注意。
ccb() {
  if [[ $# -eq 0 ]]; then
    echo "ccb: 使い方: ccb '<やってほしいこと>'" >&2
    return 1
  fi
  claude --bg "$@"
}
