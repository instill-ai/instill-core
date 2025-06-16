# Contributing Guidelines

We appreciate your contribution to this amazing project! Any form of engagement is welcome, including but not limiting to

- feature request
- documentation wording
- bug report
- roadmap suggestion
- ...and so on!

## Development and codebase contribution

Before delving into the details to come up with your first PR, please familiarize yourself with the project structure of 🔮 [**Instill Core**](https://github.com/instill-ai/instill-core).

### Prerequisites

Please refer to [prerequisites section](../README.md#prerequisites) to make sure your environment has been all set.

### Launch the local dev system

Clone the repo and launch the `latest` version of the codebase for all dependencies:

```shell
git clone https://github.com/instill-ai/instill-core.git && cd instill-core

# launch all latest service components
make latest
```

The `latest` target comes along with an env variable `PROFILE` which is intended to specify which service component you want to develop on. Available options are:

- `api-gateway`
- `mgmt`
- `pipeline`
- `model`
- `artifact`
- `console`

When you set `PROFILE={service}`, it means you want to launch that particular services. By default, `PROFILE=api-gateway,mgmt,pipeline,model,artifact,console`.
You can later on spin up and down the developed service in its dev container. Please take the [pipeline-backend](https://github.com/instill-ai/pipeline-backend/blob/main/.github/CONTRIBUTING.md#local-development) as an example.

#### Component environment variables

Some components can be configured with global secrets. This has several
applications:

- By accepting a global API key, some components have a default setup. When
  the `setup` block is omitted in the recipe, this API key will be used.
- In order to connect to 3rd party vendors via OAuth, the application
  client ID and secret must be injected.

You can set the values of these global secrets in
[`.env.secrets.component`](./.env.secrets.component) before running the Docker container in
order to add a global configuration to your components. These values will
be injected into `pipeline-backend`. Additionally, `console` will also
receive the OAuth configuration values.

### Tear down the local dev system

Simply run:

```shell
make down
```

### Build the local images

We use Docker multi-stage builds to create `instill/instill-core:{latest,release}` images, which utilize Docker-in-Docker (dind) to build all the images of **🔮 Instill Core** defined in the [docker-compose-build.yml](../docker-compose-build.yml) compose file.

You can build all the service images by running:

```shell
make build-{latest,release} BUILD_ALL_FROM_SOURCE=true
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
