def is_git_repo [] {
  git rev-parse --is-inside-work-tree | str trim | $in == "true"
}

def main [] {
  if (is_git_repo) {
    let status = (git status --porcelain)
    if ($status | is-empty) {
      print ("Git tree is clean")
    } else {
      print ("Git tree is dirty")
      print ($status)
      print ("Git add .")
      git add .
    }
  }
  exit 0
}
