# Contributing Guidelines

We appreciate your contribution to this amazing project! Any form of engagement is welcome, including but not limiting to
- feature request
- documentation wording
- bug report
- roadmap suggestion
- ...and so on!

## Development and codebase contribution

Before delving into the details to come up with your first PR, please familiarise yourself with the project structure of 🔮 [**Instill Core**](https://github.com/instill-ai/instill-core).

### Prerequisites

Please refer to [here](../README.md#prerequisites) to make sure your environment has been all set.

### Launch the local dev system

Clone the repo and launch the `latest` version of the codebase for all dependencies:

```bash
$ git clone https://github.com/instill-ai/instill-core.git && cd instill-core

# launch all latest service components
$ make latest PROFILE=all
```

The env variable `PROFILE` is intended to specify which service component you want to develop on
- `all`

  When you set `PROFILE=all`, the whole **🔮 Instill Core** stack will be launched, meaning you want to test the system as a whole.

- `{service}`

  When you set `PROFILE=exclude-{service}`, in which `{service}` can be  `pipeline`, it means you want to develop on that particular service. The `make` command will launch the corresponding stack **WITHOUT** that service component and **WITH** all other services. Given that, you can later on spin up and down the `{service}` in your dev container. Please take the [pipeline-backend](https://github.com/instill-ai/pipeline-backend#local-dev) as an example.

#### Component environment variables

Some components can be configured with global secrets. This has several
applications:

- By accepting a global API key, some components have a default setup. When
  the `setup` block is omitted in the recipe, this API key will be used.
- In order to connect to 3rd party vendors via OAuth, the application
  client ID and secret must be injected.

You can set the values of these global secrets in
[`.env.component`](./.env.component) before running the Docker container in
order to add a global configuration to your components. These values will
be injected into `pipeline-backend`. Additionally, `console` will also
receive the OAuth configuration values.

### Tear down the local dev system

Simply run:
```bash
$ make down
```

### Build the local images

We use Docker multi-stage builds to build a `instill/core:{latest,release}` image which will be based on to run dind (docker-in-docker) to build all the images of **🔮 Instill Core** defined in the compose file [docker-compose-build.yml](../docker-compose-build.yml).

You can build the images by simply running:

```bash
$ make build-{latest,release}
```

### Sending PRs

Please take these general guidelines into consideration when you are sending a PR:

1. **Fork the Repository:** Begin by forking the repository to your GitHub account.
2. **Create a New Branch:** Create a new branch to house your work. Use a clear and descriptive name, like `<your-github-username>/<what-your-pr-about>`.
3. **Make and Commit Changes:** Implement your changes and commit them. We encourage you to follow these best practices for commits to ensure an efficient review process:
   - Adhere to the [conventional commits guidelines](https://www.conventionalcommits.org/) for meaningful commit messages.
   - Follow the [7 rules of commit messages](https://chris.beams.io/posts/git-commit/) for well-structured and informative commits.
   - Rearrange commits to squash trivial changes together, if possible. Utilize [git rebase](http://gitready.com/advanced/2009/03/20/reorder-commits-with-rebase.html) for this purpose.
4. **Push to Your Branch:** Push your branch to your GitHub repository: `git push origin feat/<your-feature-name>`.
5. **Open a Pull Request:** Initiate a pull request to our repository. Our team will review your changes and collaborate with you on any necessary refinements.

When you are ready to send a PR, we recommend you to first open a `draft` one. This will trigger a bunch of `integration-test` [workflows](https://github.com/instill-ai/instill-core/tree/main/.github/workflows) running a thorough test suite on multiple platforms. After the tests are done and passed, you can now mark the PR `open` to notify the codebase owners to review. We appreciate your endeavour to pass the integration test for your PR to make sure the sanity with respect to the entire scope of **🔮 Instill Core**.

## Last words

Your contributions make a difference. Let's build something amazing together!
