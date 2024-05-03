# Update Cloudflare IP 🚀

Since not everyone is able to get a guaranteed static IP, sometimes their homelab IP address updates and the Cloudflare IP address for the DNS records also needs to update.

[![Badge: GNU Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?logo=gnubash&logoColor=white)](#readme) [![Badge: ShellCheck](https://github.com/dequeues/update-cf-ip/actions/workflows/shellcheck.yml/badge.svg?branch=master)](https://github.com/dequeues/update-cf-ip/actions/workflows/shellcheck.yml) [![Badge: GitHub](https://img.shields.io/github/license/dequeues/update-cf-ip)](https://github.com/dequeues/update-cf-ip/blob/master/LICENSE)

### Configuration

The following configuration options need to be set in the `.env` file:

```bash
CLOUDFLARE_ZONE_ID=""
NTFY_AUTH_HEADER="Authorization: Bearer YOURTOKEN"
NTFY_URL="http://127.0.0.1:9999/Notify"
CLOUDFLARE_AUTH_HEADER="Authorization: Bearer YOURTOKEN"
```
