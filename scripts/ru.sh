#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# ██                          RAJA UTILITIES                                  ██
# ██        Development environment automation toolkit for Sway WM           ██
# ═══════════════════════════════════════════════════════════════════════════════

# -----------------------------------
# CONFIGURATION
# -----------------------------------
VERSION="0.1.0"
TERMINAL="alacritty"
SHELL_CMD="zsh"
SHELL_EXEC_ARGS="-e $SHELL_CMD"
SHELL_INTERACTIVE_CMD="-ic"  # For interactive commands like nvim
# -----------------------------------
# ENTRY POINT
# -----------------------------------
ru() {
    local cmd="$1"
    shift || true
    case "$cmd" in
        op)
            ru_op "$@"
            ;;
        help|--help|-h)
            ru_help
            ;;
        version|--version|-v)
            ru_version
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Use 'ru help' for usage information."
            return 1
            ;;
    esac
}
# -----------------------------------
# HELP
# -----------------------------------
ru_help() {
    echo "Usage: ru <command> [args]"
    echo ""
    echo "Available commands:"
    echo "  op       Open project layout in Sway"
    echo "  help     Show this help message"
    echo "  version  Show version information"
    echo ""
    echo "Options (for 'op' command):"
    echo "  -pt <c|python|rust>         Project type (default: c)"
    echo "  --project-type=<type>       Same as -pt"
}

# -----------------------------------
# VERSION
# -----------------------------------
ru_version() {
    echo "Raja Utils v$VERSION"
    echo "Development environment automation toolkit for Sway WM"
}
# -----------------------------------
# COMMAND: op
# -----------------------------------
ru_op() {
    local project_type="c"
    local workspace_id=1
    local project_path=""
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -pt)
                project_type="$2"
                shift 2
                ;;
            --project-type=*)
                project_type="${1#*=}"
                shift
                ;;
            [0-9]*)  # numeric workspace id
                workspace_id="$1"
                shift
                ;;
            *)  # first non-option = project path
                if [[ -z "$project_path" ]]; then
                    project_path="$1"
                else
                    echo "Unexpected argument: $1"
                    return 1
                fi
                shift
                ;;
        esac
    done
    # Validate
    if [[ -z "$project_path" ]]; then
        echo "Error: Project path is required."
        echo "Usage: ru op <project_path> [-pt <c|python|rust>] [workspace_id]"
        return 1
    fi
    case "$project_type" in
        c|python|rust)
            ;;
        *)
            echo "Error: Unsupported project type '$project_type'"
            return 1
            ;;
    esac
    if ! command -v swaymsg >/dev/null || ! command -v "$TERMINAL" >/dev/null || ! command -v realpath >/dev/null; then
        echo "Error: Required commands not found (swaymsg, $TERMINAL, realpath)"
        return 1
    fi
    project_path="$(realpath "$project_path")"
    if [[ "$project_type" == "c" ]]; then
        ru_op_c_layout "$project_path" "$workspace_id"
    else
        echo "Project type '$project_type' not implemented yet."
        return 1
    fi
}
# -----------------------------------
# LAYOUT: C Project (default)
# -----------------------------------
ru_op_c_layout() {
    local project_path="$1"
    local workspace_id="$2"
    
    # Switch to workspace
    swaymsg "workspace number $workspace_id"
    
    # Launch first terminal with Vim - use proper alacritty syntax
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Vim' -e $SHELL_CMD -c 'nvim -c "vs"; exec $SHELL_CMD'"
    sleep 1
    
    # Split vertically (this creates top/bottom split)  
    swaymsg "split vertical"
    
    # Launch second terminal (goes to bottom)
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Build' $SHELL_EXEC_ARGS"
    sleep 1
    
    # Split the bottom container horizontally
    swaymsg "split horizontal"
    
    # Launch third terminal (goes to bottom-right)
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Run' $SHELL_EXEC_ARGS"
    sleep 1
    
    # Focus the top container and resize
    swaymsg "focus up"
    swaymsg "resize set height 90 ppt"
}
# -----------------------------------
# EXECUTION GUARD
# -----------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ru "$@"
fi
