Postfix Installation and Configuration with Gmail SMTP Relay
============================================================

This guide will walk you through setting up a Postfix mail server on Ubuntu, configuring it to use Gmail as a relay with SASL authentication, and managing virtual aliases for email forwarding.

### Prerequisites

-   A server running Ubuntu (or similar Linux distribution).
-   Access to your Gmail account to generate an app password.
-   Domain name management (DNS) through a service like OVH, and DNS records already pointing to your mail server.

* * * * *

Step 1: Install Postfix and Necessary Packages
----------------------------------------------

First, update your package list and install Postfix:

```bash
sudo apt update
sudo apt install postfix
```

During installation, you'll be prompted to select the mail server configuration type:

1.  Choose **"Internet Site"** when prompted.
2.  Set the system mail name to match your domain (e.g., `example.com`).

You can change these settings later in the `/etc/postfix/main.cf` file.

* * * * *

Step 2: Configure Postfix Main Settings
---------------------------------------

Edit the Postfix configuration file:

```bash
sudo nano /etc/postfix/main.cf
```

Update the file with the following configuration:

```json
# General settin
smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no
append_dot_mydomain = no
readme_directory = no

# TLS settings
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level = encrypt

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_security_level = encrypt
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

# SASL authentication for Gmail relay
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous

# Gmail SMTP relay configuration
relayhost = [smtp.gmail.com]:587

# Aliases for forwarding emails
virtual_alias_maps = hash:/etc/postfix/virtual

# Network and destination settings
myhostname = mail.example.com
mydestination = $myhostname, example.com, localhost.localdomain, localhost
mynetworks = 127.0.0.0/8 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all
```

### Explanation:

-   `smtp_tls_security_level = encrypt`: Ensures that the SMTP connection is encrypted.
-   `relayhost = [smtp.gmail.com]:587`: Specifies Gmail as the SMTP relay.
-   `smtp_sasl_password_maps`: Points to the file where your Gmail app password will be stored securely.
-   `virtual_alias_maps`: Defines where the virtual alias configuration is located for email forwarding.

* * * * *

Step 3: Configure SASL Authentication
-------------------------------------

To relay email through Gmail, you'll need to configure SASL authentication using a Gmail app password.

1.  **Generate a Gmail App Password**:

    -   Go to your Google Account Security settings.
    -   Under "Signing in to Google," select **App passwords**.
    -   Generate a new app password for **Mail**.
2.  **Create the SASL Password File**:

    Create and edit the `/etc/postfix/sasl_passwd` file:

    ```bash
    sudo nano /etc/postfix/sasl_passwd
    ```

    Add the following line to the file:

    ```[smtp.gmail.com]:587 your-email@gmail.com:your-app-password```

    Replace `your-email@gmail.com` with your Gmail address, and `your-app-password` with the app password you generated.

3.  **Secure and Hash the SASL Password File**:

    Set the correct permissions for the file:

    ```bash
    sudo chmod 600 /etc/postfix/sasl_passwd
    ```

    Then hash the file:

    ```bash
    sudo postmap /etc/postfix/sasl_passwd
    ```

* * * * *

Step 4: Configure Virtual Aliases
---------------------------------

To forward emails to different accounts, configure virtual aliases.

1.  **Create the Virtual Alias File**:

    Edit the `/etc/postfix/virtual` file:

    ```bash
    sudo nano /etc/postfix/virtual
    ```

    Add the following entry:

    ```user@example.com    user.forwarding@gmail.com```

    This will forward any email sent to `user@example.com` to your Gmail account.

2.  **Hash the Virtual Alias File**:

    After editing the virtual alias file, run:

    ```bash
    sudo postmap /etc/postfix/virtual
    ```

* * * * *

Step 5: Restart Postfix
-----------------------

Once all configurations are done, restart Postfix to apply the changes:

```bash
sudo systemctl restart postfix
```

You can check the status to ensure Postfix is running correctly:

```bash
sudo systemctl status postfix
```

* * * * *

Step 6: Test the Configuration
------------------------------

Send a test email to your domain email (e.g., `user@example.com`) and check your Gmail inbox to verify that it's forwarded correctly.

Additionally, you can check the mail logs for any errors or issues:

```bash
sudo tail -f /var/log/mail.log
```

* * * * *

Step 7: DNS Settings
--------------------

Ensure that your DNS records are correctly set up to handle email for your domain.

Here's an example DNS:

-   **MX Record**: Points to your mail server.

    ```example.com.      MX   10   mail.example.com.```

-   **A Record**: Points to the IP address of your mail server.

    ```mail.example.com. A    192.0.2.1```

* * * * *

Step 8: Security Considerations
-------------------------------

1.  **Secure SASL Password**: Ensure that the permissions for `/etc/postfix/sasl_passwd` and `/etc/postfix/sasl_passwd.db` are restricted to `600` to protect the Gmail app password.
2.  **Use TLS**: Always use encrypted connections (`smtp_tls_security_level = encrypt`) when relaying through Gmail.
3.  **SPF and DKIM Records**: Consider setting up SPF and DKIM records for your domain to improve email deliverability and reduce the chances of your emails being marked as spam.

* * * * *

Conclusion
----------

With this guide, you now have a fully functioning Postfix mail server that forwards emails to a Gmail account using Gmail's SMTP relay. You can further customize the configuration based on your needs, such as adding more virtual aliases or configuring additional security features.

* * * * *

This version has the domain `example.com` and a placeholder IP `192.0.2.1`, which you can replace with your actual values when setting up your server.
