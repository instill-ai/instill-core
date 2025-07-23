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

**Instill Core CE** is built with the [microservice architecture](/docs/faq#tech). We use Docker Compose for local development. Each service is nothing but a running container. Developing new features simply means to develop, containerize and deploy the new codebase.

Clone the repo and launch the system with development profile:

```shell
# Clone and move to the instill-core repository
git clone https://github.com/instill-ai/instill-core.git
cd instill-core

# Launch all services with development profile
make compose-dev
```

Once every containers are up and running, the developer can access all services through:

- [`api-gateway`](https://github.com/instill-ai/api-gateway/blob/main/config/config.yaml) (`localhost:8080`)
  - A service to handle API requests and responses.
- [`pipeline-backend`](https://github.com/instill-ai/pipeline-backend/blob/main/config/config.yaml)(`localhost:8081`)
  - A service for building and managing unstructured data pipelines.
- [`artifact-backend`](https://github.com/instill-ai/artifact-backend/blob/main/config/config.yaml)(`localhost:8082`)
  - A service for managing all RAG related resources.
- [`model-backend`](https://github.com/instill-ai/model-backend/blob/main/config/config.yaml)(`localhost:8083`)
  - A service for importing and serving AI models.
- [`mgmt-backend`](https://github.com/instill-ai/mgmt-backend/blob/main/config/config.yaml)(`localhost:8084`)
  - A service for user account management, including authentication, authorization, admission control and usage metrics.
- [`console`](https://github.com/instill-ai/console/blob/main/.env) (`localhost:3000`)
  - A service provides GUI user interface for accessing **Instill Core CE**.

### Component environment variables

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

### Developing on a specific service

Let's say, you are working on a new feature for `pipeline-backend`. You will need to remove the running containers first:

```shell
docker rm pipeline-backend
docker rm pipeline-backend-worker
```

And now move to the `pipeline-backend` codebase:

```shell
# Clone and move to the pipeline-backend repository
git clone https://github.com/instill-ai/pipeline-backend.git
cd pipeline-backend
```

#### Build and run the dev image

```shell
make compose-dev
```

Now, you have the development environment set up in the container, where you can compile and run the binaries, as well as run the integration tests in the container.

#### Start the `pipeline-backend` server

```shell
docker exec -it pipeline-backend bash
go run ./cmd/migration
go run ./cmd/init
go run ./cmd/main
```

#### Start the Temporal worker

```shell
docker exec -it pipeline-backend bash
go run ./cmd/worker
```

#### Run the integration tests

During local development, you can run the integration test to make sure your latest `pipeline-backend` works as intended:

```shell
docker exec -it pipeline-backend bash
make integration-test API_GATEWAY_URL=api-gateway:8080 DB_HOST=pg-sql
```

#### Remove the dev container

```shell
make rm
```

### Tear down the local dev system

Simply run:

```shell
make down
```

## Configurations

### Backend Services

**Instill Core CE** loads a [`.env`](https://github.com/instill-ai/instill-core/blob/main/.env) file that contains key/value pairs defining required environment variables. You can customize the file based on your configuration.

Besides, **Instill Core CE** uses [Koanf](https://github.com/knadh/koanf) library for configuration. It supports loading configuration from multiple sources and makes it available to the service. To override the default configuration, you can set the corresponding environment variables, which are passed to the Docker Compose [file](https://github.com/instill-ai/instill-core/blob/main/docker-compose.yml). Note that all configuration environment variables for each backend service are prefixed with `CFG_`.

### Frontend Console

To access Instill Core Console, set the host by overriding the environment variables:

```shellscript .env
INSTILL_CORE_HOST={HOSTNAME}
```

By default `HOSTNAME` is set to `localhost`.

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
