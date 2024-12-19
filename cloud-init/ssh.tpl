#cloud-config
# Secure SSH
ssh_pwauth: false                        # Disable password authentication
disable_root: true                       # Disable root login
disable_root_opts: no-port-forwarding,no-agent-forwarding,no-X11-forwarding
no_ssh_fingerprints: false               # Log SSH key fingerprints 
authkey_hash: sha512                     # Hash algorithm for SSH keys logging
ssh_deletekeys: true                     # Ensure old SSH host keys are deleted
ssh_genkeytypes: [ed25519, ecdsa]        # Generate only secure SSH key types (ed25519 preferred, ecdsa fallback)
allow_public_ssh_keys: true              # Allow SSH public keys for access
ssh_quiet_keygen: true                   # Suppress verbose output for key generation

## SSH Host Key Management
ssh_publish_hostkeys:
  enabled: true
  blacklist: [dsa, rsa]                  # Blacklist outdated and weak key types

ssh_authorized_keys: ${ authorized_keys }

ssh:
  emit_keys_to_console: false            # Do not emit SSH keys to console for better secrecy