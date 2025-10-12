# Tide prompt configuration
# This file contains the Tide configuration to ensure consistent prompt setup across machines
# Source this from config.fish or run manually: source ~/dotfiles/fish/tide_setup.fish

# Configure Tide automatically with the settings chosen during setup
if type -q tide
    # Basic tide configuration - Rainbow style with specific settings
    set -g tide_left_prompt_items pwd git newline character
    set -g tide_right_prompt_items status cmd_duration context jobs direnv bun node python ruby go java php rustc elixir crystal zig kubectl gcloud aws pulumi terraform docker distrobox toolbox nix_shell private_mode vi_mode time

    # Prompt style settings
    set -g tide_prompt_add_newline_before true
    set -g tide_prompt_color_frame_and_connection brblack
    set -g tide_prompt_color_separator_same_color brblack
    set -g tide_prompt_icon_connection ─
    set -g tide_prompt_min_cols 34
    set -g tide_prompt_pad_items true
    set -g tide_prompt_transient_enabled false

    # Left and right prompt frame settings
    set -g tide_left_prompt_frame_enabled false
    set -g tide_right_prompt_frame_enabled false

    # Character settings
    set -g tide_character_color brgreen
    set -g tide_character_color_failure brred
    set -g tide_character_icon ❯

    # PWD settings
    set -g tide_pwd_bg_color blue
    set -g tide_pwd_color_anchors brwhite
    set -g tide_pwd_color_dirs brwhite
    set -g tide_pwd_color_truncated_dirs white
    set -g tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .tool-versions .terraform Cargo.toml composer.json CVS go.mod package.json build.zig

    # Git settings
    set -g tide_git_bg_color green
    set -g tide_git_bg_color_unstable yellow
    set -g tide_git_bg_color_urgent red
    set -g tide_git_color_branch black
    set -g tide_git_color_conflicted black
    set -g tide_git_color_dirty black
    set -g tide_git_color_operation black
    set -g tide_git_color_staged black
    set -g tide_git_color_stash black
    set -g tide_git_color_untracked black
    set -g tide_git_color_upstream black
    set -g tide_git_truncation_length 24

    # Time settings
    set -g tide_time_bg_color white
    set -g tide_time_color black
    set -g tide_time_format '%T'

    # Status settings
    set -g tide_status_bg_color black
    set -g tide_status_bg_color_failure red
    set -g tide_status_color green
    set -g tide_status_color_failure bryellow
    set -g tide_status_icon ✔
    set -g tide_status_icon_failure ✘

    # Command duration settings
    set -g tide_cmd_duration_bg_color yellow
    set -g tide_cmd_duration_color black
    set -g tide_cmd_duration_decimals 0
    set -g tide_cmd_duration_threshold 3000

    # Context settings
    set -g tide_context_always_display false
    set -g tide_context_bg_color brblack
    set -g tide_context_color_default yellow
    set -g tide_context_color_root yellow
    set -g tide_context_color_ssh yellow
    set -g tide_context_hostname_parts 1

    # Jobs settings
    set -g tide_jobs_bg_color brblack
    set -g tide_jobs_color green
    set -g tide_jobs_number_threshold 1000
end
