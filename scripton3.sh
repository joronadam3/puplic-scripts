#!/bin/bash

# Set password policy in /etc/security/pwquality.conf
echo "Setting password policy..."
sudo bash -c 'cat > /etc/security/pwquality.conf << END
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
END'

# Set password maximum age to 180 days
echo "Setting password maximum age policy..."
sudo bash -c 'cat > /etc/login.defs << END
PASS_MAX_DAYS   180
PASS_MIN_DAYS   0
PASS_WARN_AGE   7
END'

# Force users to change their password on next login
echo "Forcing users to change their password on next login..."
for user in $(awk -F: '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd); do
    sudo chage -d 0 $user
done

# Create a script to notify users and prompt for password change
echo "Creating notification script..."
sudo bash -c 'cat > /usr/local/bin/password_policy_notify.sh << END
#!/bin/bash
zenity --info --text="The password policy has been changed. You must change your password at the next login to meet the new requirements (minimum 12 characters, including uppercase, lowercase, digits, and symbols). Your password will expire in 180 days."
passwd
gnome-session-quit --logout --no-prompt
END'

# Make the notification script executable
sudo chmod +x /usr/local/bin/password_policy_notify.sh

# Add the notification script to startup applications
echo "Adding notification script to startup applications..."
for user in $(awk -F: '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd); do
    sudo bash -c "mkdir -p /home/$user/.config/autostart"
    sudo bash -c "cat > /home/$user/.config/autostart/password_policy_notify.desktop << END
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/password_policy_notify.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Password Policy Notification
Name=Password Policy Notification
Comment[en_US]=Notify users to change their password
Comment=Notify users to change their password
END"
    sudo chown $user:$user /home/$user/.config/autostart/password_policy_notify.desktop
done

echo "Password policy has been set and users will be notified to change their password on next login."

# Schedule the script to run in 10 seconds
echo "$0" | at now + 10 seconds

echo "Password reset task scheduled to run in 10 seconds."

