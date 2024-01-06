function git_commit_all_verbose -d "git add + commit"
  if git status | grep -c "nothing to commit, working tree clean"
    git status
  else
    git add .
    git status
    git commit -v
  end
end
