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

function devbox() {
  case "$1" in
    rebuild) _devbox_rebuild ;;
    start)   _devbox_start ;;
    *)
      print "Usage: devbox <command>"
      print "  rebuild   Rebuild the devbox Docker image and load the template"
      print "  start     Connect to existing sandbox or create one in current directory"
      ;;
  esac
}
