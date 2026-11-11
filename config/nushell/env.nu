# Carapace bridges: completions from other shells' specs for commands carapace does not know.
$env.CARAPACE_BRIDGES = 'fish'

# Use the 1Password SSH agent (e.g. for git over SSH) from nushell.
$env.SSH_AUTH_SOCK = ($env.HOME | path join '.1password/agent.sock')
