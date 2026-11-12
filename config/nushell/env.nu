# Use the 1Password SSH agent (e.g. for git over SSH) from nushell.
$env.SSH_AUTH_SOCK = ($env.HOME | path join '.1password/agent.sock')

# npm settings, mirrored from uwsm/env: SSH and TTY logins don't get the graphical session's env.
$env.NPM_CONFIG_PREFIX = ($env.HOME | path join '.local/share/toolchains/npm')
$env.NPM_CONFIG_CACHE = ($env.HOME | path join '.cache/npm')
$env.NPM_CONFIG_INIT_MODULE = ($env.HOME | path join '.config/npm/npm-init.js')
