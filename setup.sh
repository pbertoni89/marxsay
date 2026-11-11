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

# ^([[:space:]]*[\/\\|<][[:space:]]) (Capture Group 1): Matches the left bubble delimiter. cowsay frames text using /, |, \, or < depending on line position. Group 1 grabs the indentation, the border delimiter, and the single space following it.
# (.*)                               (Capture Group 2): Captures the quote text itself.
# ([[:space:]][\/\\|>][[:space:]]*)$ (Capture Group 3): Matches the single space before the right border, the matching delimiter (\, |, /, or >), and trailing spaces to the end of the line.
# Replacement: \x1b[1;31m\1\x1b[1;33m\2\x1b[1;31m\3\x1b[0m
#   \x1b[1;31m\1: Paints Group 1 (left border) in bold red.
#   \x1b[1;33m\2: Switches the color to bold yellow for Group 2 (the text).
#   \x1b[1;31m\3: Switches back to bold red for Group 3 (right border).
#   \x1b[0m: Resets styling at the end of the line.
# ; t; (Conditional Branch / Test):
#   In sed, t branches to the end of the script if the preceding s/.../ replacement succeeded.
#   Because the bubble text line has already been styled, t skips any subsequent rules for that line.
# The Fallback Substitution (s/^.*$/\x1b[1;31m&\x1b[0m/):
#   Runs only on lines where the first pattern failed to match (the top ___ bar, the bottom --- bar, the speech stem \, and Tux's ASCII art).
#   Wraps the entire matching line (&) in bold red (\x1b[1;31m) and resets (\x1b[0m).
# s/o_o/\x1b[1;37m&\x1b[1;31m/g: Replaces o_o with bold white (1;37m), then switches back to red (1;31m) so the surrounding line stays red.
# s/:_\//\x1b[1;33m&\x1b[1;31m/g: Replaces :_/ with bold yellow (1;33m), then switches back to red. Note that / is escaped as \/.
# s/^.*$/\x1b[1;31m&\x1b[0m/: Wraps whatever is left on that line in red.

usrRc="${HOME}/.bashrc"
defaultHello="marxsay-red"   # Options: marxsay, marxsay-col, marxsay-red, or ""

# Use a unique tag so running setup.sh multiple times won't create duplicates
if ! grep -q "# MARXSAY_CONFIG_START" "$usrRc"; then
    echo "Writing configuration to $usrRc..."
    cat << EOF >> "$usrRc"

# MARXSAY_CONFIG_START
alias marxsay='fortune ~/.fortunes/marxism | cowsay -f tux'
alias marxsay-col='fortune ~/.fortunes/marxism | cowsay -f tux | lolcat -F 0.3'

marxsay-red() {
    fortune ~/.fortunes/marxism | cowsay -f tux | sed -E '
        s/^([[:space:]]*[\/\\\\|<][[:space:]])(.*)([[:space:]][\/\\\\|>][[:space:]]*)$/\\x1b[1;31m\\1\\x1b[1;33m\\2\\x1b[1;31m\\3\\x1b[0m/; t
        s/o_o/\\x1b[1;37m&\\x1b[1;31m/g
        s/:_\\//\\x1b[1;33m&\\x1b[1;31m/g
        s/^.*$/\\x1b[1;31m&\\x1b[0m/
    '
}

# Startup quote
${defaultHello}
# MARXSAY_CONFIG_END
EOF
else
    echo "Marx Tux configuration is already present in $usrRc (skipping write)."
fi

# 4. Display a test output directly via pipeline
echo "Installation complete. Test it with marxsay*"
