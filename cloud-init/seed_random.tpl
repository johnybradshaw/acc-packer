#cloud-config
# Seed random number generator
random_seed:
  file: /dev/urandom
  command: ["pollinate", "-r"]
  command_required: true