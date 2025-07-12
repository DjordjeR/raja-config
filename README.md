# Raja Config

This repository contains my personal configurations and utility scripts used to set up and manage my development environment.

By leveraging [Bombadil](https://github.com/oknozor/bombadil), configuration files and scripts are easily managed, deployed, and version-controlled across multiple systems.

## What’s inside

- Dotfiles and configs for various tools and environments (e.g., `nvim`, `zsh`, `sway`, `waybar`, and more)
- Utility scripts for automation and setup

## Getting Started

Use Bombadil to install and manage your dotfiles with minimal effort:

```bash
# Create symlinks for all configured files
bombadil link --force

# To remove symlinks created by Bombadil
bombadil unlink

# To check what Bombadil will link/unlink without making changes
bombadil dry-run
```

This will symlink all configured files according to the `bombadil.toml` manifest.

## Contributing

This repository is primarily for personal use, but feel free to explore and adapt as needed.

## License

This project is open-source under the [MIT License](LICENSE).
