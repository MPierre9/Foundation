#!/bin/bash
# NOTE: should put this file in a central spot and make an alias to reference it.
set -euo pipefail

##### TAIL #######################################################

# Show last N lines (instead of default 10)
tail -n 50 file.log

# Follow multiple files simultaneously
tail -f file1.log file2.log

# Print headers when showing multiple files
tail -v file1.log file2.log

# Follow the file by name (even if rotated/deleted)
tail -F file.log

################################################################



##### HEAD #######################################################

# Show first N lines (instead of default 10)
head -n 20 file.txt

################################################################



##### TOP #######################################################

# Update every 3 seconds (default is 1)
top -d 3

# Show only specific user's processes 
top -u username

################################################################


##### DIG #######################################################
# Useful for troubleshooting Route 53, DNS resolution, and service discovery issues in AWS. Essential for validating DNS records,
# checking propagation, and verifying domain configurations.

# Basic DNS lookup
dig example.com

# Query specific record type
dig example.com A
dig example.com CNAME

# Trace DNS resolution (+trace)
dig +trace example.com

# Short answer only
dig +short example.com


##### NSLOOKUP #######################################################

# Basic nslookup
nslookup example.com

# Query specific record type
nslookup -type=A example.com

# Debug mode
nslookup -debug example.com

##### JQ

# Basic select - get value of specific field
echo '{"name": "John", "age": 30}' | jq '.name'
# Output: "John"

# Select nested field
echo '{"user": {"name": "John", "details": {"city": "Boston"}}}' | jq '.user.details.city'
# Output: "Boston"

# (there's also yq for YAML docs)

##### XARGs
# xargs is a Unix command that reads items from standard input (like a list of filenames or strings) and executes a command using those items as arguments.
# It's particularly useful when you want to run a command multiple times using different inputs, or when you have more arguments than a command can normally handle.

# Without xargs (using loop)
# for file in *.txt; do 
#     cat "$file"
# done

# # With xargs
# ls *.txt | xargs cat


##### VIM BIBLE

# Source another vimrc
:source ./my_other_vimrc

# Search
/hello     # Search forward for "hello"
?hello     # Search backward for "hello"
n          # Next match
N          # Previous match
:nohl      # Clear search highlighting


# Editing
dd         # Delete (cut) entire line
yy         # Copy entire line
p          # Paste after cursor
P          # Paste before cursor
u          # Undo last change
ctrl+r     # Redo last change
x          # Delete character under cursor
r          # Replace single character
cw         # Change (replace) word
D          # Delete from cursor to end of line
C          # Change from cursor to end of line

# Moving through document
ctrl+f     # Page down (Forward)
ctrl+b     # Page up (Backward)
gg         # Go to beginning of file
G          # Go to end of file
:42        # Go to line 42
0          # Go to beginning of line
^          # Go to first non-blank character of line
$          # Go to end of line
w          # Jump to start of next word
b          # Jump to start of previous word
e          # Jump to end of word

# Set line numbers
:set number


#### VSCODE
# (Note: using my custom keybindings too)
## ctrl + tab: cycle through open files in editor
## cmd + $NUM: select that number tab file

## option + cmd + n: new folder
## cmd + n: new file


#### LOCAL ENV
printenv (cenv) 

unset $NAME # to unset a env variable


#### EXTRA 

https://gist.github.com/kevin-smets/8568070 (extra iterm setup)