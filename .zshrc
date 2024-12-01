# ALIASES #


## General Aliases #

export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
alias l='ls -Glatrh'
alias tailf='tail -f'

alias ..='cd ..'

alias ....='cd ../../'
alias ......='cd ../../../'

alias h='history'  # Shows command history

alias path='echo -e ${PATH//:/\\n}' # see what in your PATH

alias cenv='printenv | grep --color=always "^[^=]*=\|$"'

# File Search and Text Search Aliases
alias ffind='find . -type f -not -path "*/\.*" -name'  # Find files (ignore hidden)
    # Example: ffind *Outdoor*.pdf"

alias grep='grep --color=auto'
alias fgrep='grep -r --color=auto'  # Recursive grep
alias repeat='watch -n'
    # Example: grep -r --color=auto "gamecube" .

## Python Aliases

alias venv3='python3 -m venv'
alias venv='python -m venv'

## Git Aliases

# Rebase workflow
# Example scenario: 
# You're working on feature branch and main has new changes.
# Instead of:
#   git checkout main
#   git pull
#   git checkout your-branch
#   git merge main
# Better to use rebase:
#   git fetch origin
#   git rebase origin/main
# This keeps history clean and avoids merge commits.
# These aliases help with that workflow:

alias grm='git fetch origin && git rebase origin/main'  # Rebase current branch on main
alias grc='git rebase --continue'                       # After resolving conflicts
alias gra='git rebase --abort'                          # If rebase goes wrong

# The most common workflow using these would be:
# 1. Working on your-feature-branch and need main's changes
# 2. Run: grm
# 3. If conflicts: fix them, git add files, then grc
# 4. If it gets messy: gra to start over

# Status & Branch
alias gs='git status'
alias gb='git branch'
alias gba='git branch -a'

# Common actions
alias gco='git checkout'
alias gcob='git checkout -b'
alias gc='git commit -m'
alias ga='git add'
# git reset --hard origin/main (just good to know)


# System Debugging Aliases (good)
alias dmesg-live='dmesg -wH'  # Watch kernel messages in human readable format
alias ports='netstat -tulanp'  # Show all active ports (only works on linux)
alias meminfo='free -h -w'    # Memory info in human readable format
alias dfh='df -h'             # Disk usage in human readable format
alias duh='du -h --max-depth=1 | sort -hr'  # Directory sizes, sorted
alias psmem='ps aux | sort -nr -k 4 | head -10'  # Top 10 memory consuming processes
alias pscpu='ps aux | sort -nr -k 3 | head -10'  # Top 10 CPU consuming processes
alias cpuinfo='lscpu' # Get server cpu info


# AWS ECR Aliases

# Basic ECR login
alias ecr-login='aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com'

# List repositories
alias ecr-ls='aws ecr describe-repositories --query "repositories[*].repositoryName" --output table'

# List images in a repository
alias ecr-images='aws ecr describe-images --repository-name'

# AWS EC2 Aliases
alias ec2-ls='aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].{Name:Tags[?Key==\`Name\`]|[0].Value,InstanceId:InstanceId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,State:State.Name}" \
  --output table \
  --filters "Name=instance-state-name,Values=running"'

# AWS S3 Aliases
alias s3ls='aws s3 ls | awk -v OFS="\t" '\''{
    # Color codes
    BLUE="\033[34m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    RESET="\033[0m"
    
    # Format date/time, bucket name
    printf "%s%s %s%s%s%s%s\n", 
        GREEN, $1" "$2,  # Date and time in green
        YELLOW, $3,      # Size in yellow
        BLUE, $4,        # Bucket name in blue
        RESET
}'\'''

# AWS SSM Session Manager Aliases
## Install the plugin https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html
alias ssm-connect='function _ssm() { aws ssm start-session --target "$1"; }; _ssm'

# AWS ECS Aliases
alias ecs-clusters='aws ecs list-clusters | jq -r ".clusterArns[]"'
alias ecs-services='function _ecs_services() { aws ecs list-services --cluster "$1" | jq -r ".serviceArns[]"; }; _ecs_services'
    # Usage: ecs-services my-production-cluster

alias ecs-tasks='function _ecs_tasks() { aws ecs list-tasks --cluster "$1" --service-name "$2" | jq -r ".taskArns[]"; }; _ecs_tasks'
    # Usage: ecs-tasks my-production-cluster web-app

alias ecs-exec='function _ecs_exec() { aws ecs execute-command --cluster "$1" --task "$2" --container "$3" --command "/bin/bash" --interactive; }; _ecs_exec'
    # Usage: ecs-exec my-production-cluster abcd1234efgh5678 web-app-container

alias ecs-logs='function _ecs_logs() { aws logs get-log-events --log-group-name "$1" --log-stream-name "$2" | jq -r ".events[].message"; }; _ecs_logs'
    # Usage: ecs-logs /ecs/my-production-cluster/web-app web-app/abcd1234-efgh-5678-ijkl-9012mnop3456

# AWS EKS Aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kns='kubectl config set-context --current --namespace'

# EKS Cluster Management
alias eks-list='aws eks list-clusters | jq -r ".clusters[]"'
alias eks-update='function _eks_update() { aws eks update-kubeconfig --name "$1"; }; _eks_update'


