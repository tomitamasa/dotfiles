function git_commit_all_verbose -d "Add all changes and commit with verbose mode"
    git add -A
    git commit -v $argv
end
