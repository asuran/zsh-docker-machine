# zsh-docker-machine
Docker-machine plugin for oh-my-zsh

## Future features:

- append $DOCKER_MACHINE_NAME and $MACHINE_STATUS to the theme string
- machine name completion
- machine list
- switch -d <machine_name> → cd %machine_name_directory%
- switch -p → pstorm %machine_name_directory%
- working with multiple flags (e.g dmachine switch -d -p)
- run external tools (e.g. docker-machine-dns) via hooks
