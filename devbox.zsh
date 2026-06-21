_DEVBOX_DIR="${${(%):-%x}:A:h}"
_DEVBOX_IMAGE="gerrietts.net/devbox-template:v1.0"
_DEVBOX_TEMPLATE="${_DEVBOX_DIR}/target/devbox-template.tar"

function _devbox_rebuild() {
  local target="${_DEVBOX_DIR}/target"
  [[ -d "$target" ]] || mkdir "$target"
  docker build -t "$_DEVBOX_IMAGE" "$_DEVBOX_DIR"
  docker image save "$_DEVBOX_IMAGE" -o "$_DEVBOX_TEMPLATE"
  sbx template load "$_DEVBOX_TEMPLATE"
}

function _devbox_start() {
  local sandbox_name="claude-$(basename $(pwd))"
  if sbx ls 2>/dev/null | grep -qF "$sandbox_name"; then
    sbx run "$sandbox_name"
  else
    sbx run --template "$_DEVBOX_IMAGE" claude
  fi
}

function _devbox_update() {
  source "${_DEVBOX_DIR}/devbox.zsh"
}

function _devbox_remove() {
  if [[ "$1" == "all" ]]; then
    sbx ls 2>/dev/null | tail -n +2 | awk '{print $1}' | while read -r name; do
      sbx rm "$name"
    done
  elif [[ -n "$1" ]]; then
    sbx rm "$1"
  else
    local sandbox_name="claude-$(basename $(pwd))"
    sbx rm "$sandbox_name"
  fi
}

function devbox() {
  case "$1" in
    rebuild) _devbox_rebuild ;;
    start|run) _devbox_start ;;
    update)  _devbox_update ;;
    remove)  _devbox_remove "$2" ;;
    *)
      print "Usage: devbox <command>"
      print "  rebuild      Rebuild the devbox Docker image and load the template"
      print "  start|run    Connect to existing sandbox or create one in current directory"
      print "  update       Reload devbox.zsh"
      print "  remove [name|all]  Remove a sandbox (default: cwd sandbox)"
      ;;
  esac
}
