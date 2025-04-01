#!/bin/bash

# Setup SSH Keys
setup_ssh() {
    mkdir -p ~/.ssh
    
    # Setup Target Server SSH key
    echo "$TARGET_SSH_PRIVATE_KEY" > ~/.ssh/target_key
    echo "" >> ~/.ssh/target_key
    chmod 600 ~/.ssh/target_key
    
    # Create SSH config file
    cat > ~/.ssh/config << EOF
Host target
    HostName $TARGET_HOST
    User $TARGET_USER
    IdentityFile ~/.ssh/target_key
    StrictHostKeyChecking no
EOF
    
    # If bridge host is configured, add bridge configuration
    if [ ! -z "$BRIDGE_HOST" ]; then
        echo "$BRIDGE_SSH_PRIVATE_KEY" > ~/.ssh/bridge_key
        echo "" >> ~/.ssh/bridge_key
        chmod 600 ~/.ssh/bridge_key
        
        # Add bridge configuration
        cat >> ~/.ssh/config << EOF

Host bridge
    HostName $BRIDGE_HOST
    User $BRIDGE_USER
    IdentityFile ~/.ssh/bridge_key
    StrictHostKeyChecking no
EOF
    fi
    
    chmod 600 ~/.ssh/config
}

# Execute remote command
execute_remote_command() {
    if [ ! -z "$BRIDGE_HOST" ]; then
        ssh bridge "ssh $TARGET_HOST \"cd $APP_DIRECTORY && make upgrade_seadoc\""
    else
        ssh target -p "$TARGET_PORT" "cd $APP_DIRECTORY && make upgrade_seadoc"
    fi
}

# Main execution
setup_ssh
execute_remote_command 