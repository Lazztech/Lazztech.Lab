# Gitea

Gitea is a self hosted git repository service. It's lighter weight than gitlab and has a MIT license so it doesn't require the cost of per user licenses. It is used here as a local mirror of github repositories.

## Mirroring Github Repositories

1. Go to https://git.lazz.tech
2. Click the plus in the top right and then select "New Migration"
3. Select Github
4. Add a url to a repo for example "https://github.com/Lazztech/Lazztech.Infrastructure.git"
5. Supply a github access token to be used by gitea
6. Check "This repository will be a mirror"
7. Click "Migrate Repository"

Related resources:
- https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token