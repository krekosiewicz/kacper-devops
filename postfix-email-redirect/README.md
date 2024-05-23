# Example .env
```
MAILNAME=<yourdomain>
SMTP_USER=<username>:password
EMAIL_FROM=<username>@<yourdomain>
EMAIL_TO=<destinationEmail>
```

# Example DNS Configuration
Here is how the DNS configuration might look in your DNS provider’s interface:

| Type | Name | Value | Priority |
|------|------|-------|----------|
| MX   | @    | mail.[yourdomain]. | 10       |
| A    | mail | [Your Postfix server IP] | N/A |


# How to run
```shell
docker network create email-network
docker-compose --env-file <.yourEnvFile> up -d

```