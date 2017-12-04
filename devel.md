# Developer specifications

This file contains the specifications of the setup to automatically generate and publish the course pack.

If you are here to make edits to the text, please have a look at `readme.md`.

## Continuous integration

### Deploying to GitHub pages

Our deployment process does not use the official Travis deployment to GitHub pages [documented here](https://docs.travis-ci.com/user/deployment/pages/). We cannot use this process because we cannot generate the [GitHub personal access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) which is required to authenticate with GitHub. The token-based access is only available for personal GitHub accounts and not for organisation and this repo is currently owned by the `LSE-Methodology` organisation.

Our setup uses an SSH key to authenticate with GitHub. SSH keys can be added to the repo as [deploy keys](https://developer.github.com/v3/guides/managing-deploy-keys/) and give access to a single repo.

Setting this up comprises four steps:

1. Generate a new SSH key **without a password**. This means that the key will not be encrypted and whoever has the key file will have access to the repo.
2. Encrypt with `travis` such that it can be checked into git but only the travis host can make use of the key. The file in the repo is now encrypted and only travis knows how decrypt it.
3. Configure the deploy process to use the key when upload.
4. Add the public part of the new key as a deploy key on GitHub.

#### Detailed steps

Make sure that you `cd`'d into the local copy of the git repo. Also make sure that you have the `travis` ruby gem installed via `gem install travis`.

Generate a new SSH key. **Important**: Ensure that you leave the password prompt empty such that an unencrypted key is generated.

```sh
ssh-keygen -t rsa -b 4096 -o -f id_rsa
```

Now encrypt the key for use by Travis following [the official file encryption guide](https://docs.travis-ci.com/user/encrypting-files/). First log in to Travis (use your GitHub credentials as prompted) and then encrypt the file.

```sh
travis login
travis encrypt-file id_rsa --add
```

This will add a line like the following to `.travis.yml`.

```
openssl aes-256-cbc -K $encrypted_0a6446eb3ae3_key -iv $encrypted_0a6446eb3ae3_iv -in super_secret.txt.enc -out super_secret.txt -d
```

Now edit `.travis.yml` to complete the setup. First move the added line to the `before_deploy` section. Then, the generated file needs to be moved to `$HOME/.ssh` such that it is recognised as the default SSH key. Also, SSH will refuse to use a key if the access permissions are too permissive so make sure that only the owner of the file can read and write to it via `chmod`. Finally, configure git to use the Travis deployment bot as the user.

```yaml
before_deploy:
- openssl aes-256-cbc -K $encrypted_8142622f9176_key -iv $encrypted_8142622f9176_iv -in id_rsa.enc -out id_rsa -d
- chmod 600 id_rsa
- mkdir -p $HOME/.ssh
- mv id_rsa $HOME/.ssh
- git config --global user.email "deploy@travis-ci.org"
- git config --global user.name "Deployment Bot"
```

The deployment script `_deploy.sh` is then quite simple. You can specify the directory that should be deployed by setting `DEPLOY_DIR`. This is currently `_book` where bookdown puts the built files. The script the initialises a new git repo in the specified folder, adds and commits all the files and pushes them to the `gh-pages` branch.

An important thing to note here is that the push is **forced** so we retain no history of the `gh-pages` branch. If you want to look at the history before we changed the deployment process to the current one, have a look at the `gh-pages-old` branch.

```sh
#!/bin/sh

set -e

# Name of the folder to deploy (use "." for root directory)
DEPLOY_DIR=_book

# Deploy with an empty history
cd ${DEPLOY_DIR}
git init
git add .
git commit -m "Update GitHub pages to ${TRAVIS_COMMIT}"
git push --force --quiet "git@github.com:${GITHUB_REPO}.git" master:gh-pages
```

Finally, register the key as a deployment key with push access. Head to [the settings page for deploy keys](https://github.com/LSE-Methodology/MY451/settings/keys) and add the content of `id_rsa.pub` as a deploy key. Make sure to tick **allow write access**.

As the very last step, delete `id_rsa` and `id_rsa.pub` in the current directory which are not needed anymore.
