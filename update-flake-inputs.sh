#!/usr/bin/env nu

# TUI script for updating flake inputs.
# Usage: ./update-flake-inputs.sh

const flake_dir = path self .
const flake_file = path self flake.nix
const update_all = "[update-all-inputs]"

def indentation [line: string] {
  ($line | str length) - ($line | str trim --left | str length)
}

# Read inputs already present in flake.lock without requiring jq.
def get_locked_inputs [] {
  let lock_file = ($flake_dir | path join "flake.lock")

  if not ($lock_file | path exists) {
    return []
  }

  try {
    open --raw $lock_file
    | from json
    | get nodes.root.inputs
    | columns
  } catch {
    []
  }
}

# Extract direct children of the inputs attrset from flake.nix so newly added,
# not-yet-locked inputs are available too. Supports `name = { ... };` and
# the shorthand `name.url = "...";`.
def get_declared_inputs [] {
  let state = (
    open --raw $flake_file
    | lines
    | reduce --fold {
        in_inputs: false
        done: false
        inputs_indent: 0
        input_indent: null
        inputs: []
      } {|line, state|
        if $state.done {
          $state
        } else {
          let trimmed = ($line | str trim --left)
          let line_indent = (indentation $line)

          if not $state.in_inputs {
            if $line =~ '^\s*inputs\s*=\s*\{' {
              $state
              | upsert in_inputs true
              | upsert inputs_indent $line_indent
            } else {
              $state
            }
          } else if $line_indent <= $state.inputs_indent and ($trimmed | str starts-with "};") {
            $state
            | upsert in_inputs false
            | upsert done true
          } else if (
            ($trimmed =~ '^[a-zA-Z0-9_-]+\s*=\s*\{')
            or ($trimmed =~ '^[a-zA-Z0-9_-]+[.]url\s*=')
          ) {
            let input_indent = if $state.input_indent == null {
              $line_indent
            } else {
              $state.input_indent
            }

            if $line_indent == $input_indent {
              let input_name = (
                $trimmed
                | str replace --regex '[.]url\s*=.*$' ''
                | str replace --regex '\s*=.*$' ''
              )

              $state
              | upsert input_indent $input_indent
              | upsert inputs ($state.inputs | append $input_name)
            } else {
              $state
            }
          } else {
            $state
          }
        }
      }
  )

  $state.inputs
}

def update_input [input_name: string] {
  let nix_flags = if $nu.os-info.name == "macos" {
    [--extra-experimental-features "nix-command flakes"]
  } else {
    []
  }

  if $input_name == $update_all {
    print $"(ansi cyan)Updating all inputs...(ansi reset)"
    ^nix ...$nix_flags flake update --flake $flake_dir
  } else {
    print $"(ansi cyan)Updating input: (ansi yellow)($input_name)(ansi reset)"
    ^nix ...$nix_flags flake update --flake $flake_dir $input_name
  }

  if $env.LAST_EXIT_CODE != 0 {
    exit $env.LAST_EXIT_CODE
  }
}

def main [] {
  print $"(ansi blue)╔══════════════════════════════════╗(ansi reset)"
  print $"(ansi blue)║     (ansi cyan)Nix Flake Inputs Updater(ansi blue)     ║(ansi reset)"
  print $"(ansi blue)╚══════════════════════════════════╝(ansi reset)"
  print ""

  if not ($flake_file | path exists) {
    print --stderr $"(ansi red)Error: flake.nix not found at ($flake_file)(ansi reset)"
    exit 1
  }

  print $"(ansi cyan)Parsing flake.nix for inputs...(ansi reset)"

  let inputs = (
    (get_locked_inputs)
    | append (get_declared_inputs)
    | uniq
    | sort
  )

  if ($inputs | is-empty) {
    print --stderr $"(ansi red)No inputs found in flake.nix(ansi reset)"
    exit 1
  }

  print ""
  print $"(ansi cyan)Select an input to update; the first option updates all inputs.(ansi reset)"

  let selected = try {
    [$update_all]
    | append $inputs
    | input list --fuzzy "Select input"
  } catch {
    null
  }

  if $selected == null {
    print ""
    print $"(ansi yellow)No input selected. Exiting.(ansi reset)"
    return
  }

  print ""
  if $selected == $update_all {
    print $"(ansi green)You selected: Update ALL inputs(ansi reset)"
  } else {
    print $"(ansi green)You selected input: (ansi cyan)($selected)(ansi reset)"
  }

  print ""
  let confirmation = (input --default "y" "Proceed with update? [Y/n]: " | str trim | str lowercase)
  if $confirmation not-in ["" "y" "yes"] {
    print $"(ansi yellow)Update cancelled.(ansi reset)"
    return
  }

  print ""
  update_input $selected

  print ""
  print $"(ansi green)✓ Update complete!(ansi reset)"
}
