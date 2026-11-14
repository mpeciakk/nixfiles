# Replaces the completer that carapace's own init installs: expands the whole
# alias (`ga` -> `git add .`), not only its first word, and skips carapace for
# docker. Sourced after init.nu (which sources carapace/init.nu), so this
# assignment wins.
let carapace_completer = {|spans: list<string>|
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

$env.config.completions.external.completer = {|place|
    let spans = $place.command
    # Expand a leading alias to its real command so completions match it
    # (e.g. `ga ` -> `git add . `), keeping the rest of the typed words.
    let expanded = scope aliases | where name == $spans.0 | get -o 0.expansion
    let spans = if $expanded != null {
        $spans | skip 1 | prepend ($expanded | split row ' ')
    } else { $spans }

    match $spans.0 {
        docker => null                      # no carapace for docker; nushell falls back
        _ => (do $carapace_completer $spans)
    }
}
