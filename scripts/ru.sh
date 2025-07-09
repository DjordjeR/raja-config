#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# ██                          RAJA UTILITIES                                  ██
# ██        Development environment automation toolkit for Sway WM            ██
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
        ds)
            ru_ds "$@"
            ;;
        help|--help|-h)
            ru_help
            ;;
        version|--version|-v)
            ru_version
            ;;
        *)
            echo "Unknown command: $cmd" >&2
            echo "Use 'ru help' for usage information." >&2
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
    echo "  ds       Display setup: '<laptop|dock|toggle>'"
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
                    echo "Unexpected argument: $1" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    # Validate
    if [[ -z "$project_path" ]]; then
        echo "Error: Project path is required." >&2
        echo "Usage: ru op <project_path> [-pt <c|python|rust>] [workspace_id]" >&2
        return 1
    fi
    if [[ ! -d "$project_path" ]]; then
        echo "Error: Project path '$project_path' does not exist or is not a directory." >&2
        return 1
    fi

    case "$project_type" in
        c|python|rust)
            ;;
        *)
            echo "Error: Unsupported project type '$project_type'" >&2
            return 1
            ;;
    esac
    if ! command -v swaymsg >/dev/null 2>&1 || ! command -v "$TERMINAL" >/dev/null 2>&1 || ! command -v realpath >/dev/null 2>&1; then
        echo "Error: Required commands not found (swaymsg, $TERMINAL, realpath)" >&2
        return 1
    fi
    project_path="$(realpath "$project_path" 2>/dev/null)"
    if [[ "$project_type" == "c" ]]; then
        ru_op_c_layout "$project_path" "$workspace_id"
    else
        echo "Project type '$project_type' not implemented yet." >&2
        return 1
    fi
}
# -----------------------------------
# LAYOUT: C Project (default)
# -----------------------------------

ru_op_c_layout() {
    local project_path="$1"
    local workspace_id="$2"

    swaymsg "workspace number $workspace_id" >/dev/null

    # Launch Vim (top)
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Vim' -e $SHELL_CMD -c 'nvim \"$project_path\" -c \"vs\"; exec $SHELL_CMD'" >/dev/null
    sleep 0.3

    # Split vertically (bottom)
    swaymsg "split vertical" >/dev/null
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Build' $SHELL_EXEC_ARGS" >/dev/null
    sleep 0.3

    # Split horizontally (right bottom)
    swaymsg "split horizontal" >/dev/null
    swaymsg "exec $TERMINAL --working-directory \"$project_path\" --title 'Run' $SHELL_EXEC_ARGS" >/dev/null
    sleep 0.3

    # Focus Vim (up) and resize
    swaymsg "focus up" >/dev/null
    swaymsg "resize set height 90 ppt" >/dev/null
}


# -----------------------------------
# COMMAND: ds (Display Setup)
# -----------------------------------
ru_ds() {
    local mode="$1"

    if [[ -z "$mode" ]]; then
        echo "Error: Mode is required. Usage: ru ds <laptop|dock|toggle>" >&2
        return 1
    fi

    if ! command -v swaymsg >/dev/null 2>&1; then
        echo "Error: swaymsg command not found." >&2
        return 1
    fi

    case "$mode" in
        laptop)
            # Build disable commands for all external outputs except eDP-1
            local disable_cmds=""
            while IFS= read -r output; do
                disable_cmds+="output $output disable; "
            done < <(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1") | .name' 2>/dev/null)

            # Run atomic command to enable laptop screen + disable others, suppress stdout
            swaymsg "output eDP-1 enable scale 1.5 resolution 2560x1440; ${disable_cmds}" >/dev/null
            echo "Switched to laptop mode."
            ;;
        dock)
            mapfile -t external_outputs < <(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.name != "eDP-1") | .name' 2>/dev/null | sort 2>/dev/null)

            if [[ ${#external_outputs[@]} -lt 1 ]]; then
                echo "Error: No external displays found." >&2
                return 1
            fi

            local left="${external_outputs[-1]}"
            local right="${external_outputs[0]}"

            swaymsg "output $left enable; output $right enable; output $left pos 0 0; output $right pos 1920 0; output eDP-1 disable" >/dev/null
            echo "Switched to dock mode."
            ;;
        toggle)
            local eDP_status
            eDP_status=$(swaymsg -t get_outputs | jq -r '.[] | select(.name=="eDP-1") | .active' 2>/dev/null)

            if [[ "$eDP_status" == "true" ]]; then
                ru_ds dock
            else
                ru_ds laptop
            fi
            ;;
        *)
            echo "Error: Unknown mode '$mode'. Use 'laptop', 'dock' or 'toggle'." >&2
            return 1
            ;;
    esac
}

# -----------------------------------
# EXECUTION GUARD
# -----------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ru "$@"
fi

