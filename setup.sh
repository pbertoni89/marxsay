#!/bin/bash

# https://gemini.google.com/app/1ee2ee1048b18ada
# https://gemini.google.com/app/2f643d8957536e17

pkgInst=()
for pkg in fortune-mod cowsay lolcat; do
    dpkg -s "$pkg" &>/dev/null || pkgInst+=("$pkg")
done

if (( ${#pkgInst[@]} > 0 )); then
    echo "Installing missing packages: ${pkgInst[*]}"
    sudo apt update
    sudo apt install -y "${pkgInst[@]}"
else
    echo "All required packages are already installed."
fi

dirThis="$(dirname "${BASH_SOURCE[0]}")"
dirDat=~/.fortunes
mkdir -p ${dirDat}

# 1. Copy the text file without the .txt extension so base names align
cp "${dirThis}/marxism.txt" "${dirDat}/marxism"

# 2. Build the binary index (~/.fortunes/marxism.dat)
strfile "${dirDat}/marxism" "${dirDat}/marxism.dat"

# 3. Append aliases to ~/.bashrc (checking first to prevent duplicates)
usrRc="${HOME}/.bashrc"
defaultHello="marxsay-col"
defaultHello="marxsay-red"
aliases=(
    "alias marxsay='fortune ~/.fortunes/marxism | cowsay -f tux'"
    "alias marxsay-col='fortune ~/.fortunes/marxism | cowsay -f tux | lolcat -F 0.3'"
    "alias marxsay-red='fortune ~/.fortunes/marxism | cowsay -f tux | sed -E '\''s/^([[:space:]]*[\/\\|<][[:space:]])(.*)([[:space:]][\/\\|>][[:space:]]*)$/\x1b[1;31m\1\x1b[1;33m\2\x1b[1;31m\3\x1b[0m/; t; s/^.*$/\x1b[1;31m&\x1b[0m/'\'''"
    "${defaultHello}"
)

for al in "${aliases[@]}"; do
    grep -qxF "${al}" "${usrRc}" || echo "${al}" >> "${usrRc}"
done

# 4. Display a test output directly via pipeline
echo "Installation complete. Testing colored Tux:"
newgrp
marxsay
marxsay-col
marxsay-red
