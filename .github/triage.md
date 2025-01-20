# Issues Triage Process

The triage process is designed to swiftly categorize new issues and pull requests (PRs) and take appropriate actions whenever possible.

As a new issue/PR is created, the community initiates conversations, applies suitable labels, and seeks additional information.

At Instill AI, we conduct regular triage meetings. These meetings focus on unresolved issues/PRs where consensus has not been reached, and aim to determine whether and when they should be incorporated into our roadmap.

## Triage Stages

| Name   | Description                                                                                                                                                                                                                                                                                                                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Triage | When a new issue/PR is opened, it is automatically labeled as `need triage``. Maintainers assign core members as reviewers to assess the issue/PR's characteristics. Reviewers initiate conversations with the creator of the issue/PR and apply relevant labels. If there's consensus and the issue/PR requires detailed planning, reviewers remove the `need triage`` label and add the `linear` label. |
| Plan   | Issues/PRs with the `linear` label are thoroughly reviewed and need to be planned. Reviewers determine if the issue/PR is suitable for community contribution, whether it can be added to the backlog, and discuss its potential inclusion in the roadmap and the timing thereof.                                                                                                                         |

We anticipate that most issues/PRs can follow this path, leading to efficient asynchronous resolution without waiting for triage meetings. Issues/PRs labeled as `need discussion` will be addressed during these triage meetings.

👉 Please refer to the [triage process diagram](https://app.eraser.io/workspace/0cadbV6boFtr9NUcAGMH?elements=4FnFqsyPSnm7QMlVlvnFkg) for visual representation.

## Labels

GitHub labels assist in annotating issues/PRs with additional information. Our community uses labels, as outlined below, to convey information and facilitate decision-making regarding issues/PRs.

### Communication Labels

These labels convey the status of the triage process for an issue/PR and indicate areas where community contribution is needed. Many communication labels are replaced by other labels as the triage process progresses and the issue enters active development. For instance, the `help wanted` label is removed once an issue moves into active development and a community member takes ownership. Below are the labels in this category:

| <div style="width:150px">Label</div> | Indicates that                                                                                                                                  |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `need triage`                        | Issue/PR needs triaging                                                                                                                         |
| `question`                           | The issue/PR creator needs to provide more information for meaningful triaging. When adding this label, comment about the required information. |
| `need discussion`                    | This issue/PR necessitates discussion during triage meetings. When adding this label, comment about what aspects require discussion.            |
| `good first issue`                   | Issue suitable for first-time contributors                                                                                                      |
| `help wanted`                        | Issue complexity suitable for external contributors                                                                                             |

### Metadata Labels

These labels enrich issues/PRs with metadata to aid the triage process and active development. These labels may not be removed from issues/PRs, although their values may change as development progresses. For example, the priority label may change from `priority: low` to `priority: high` as the roadmap is updated. Here is the list of labels in this category:

| <div style="width:150px">Label</div> | Indicates that                                                                                                                                                                                                                        |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<project>`                          | Instill Project related to this issue/PR. E.g., 'instill vdp', 'instill model', 'instill core', 'instill console', 'instill cli' and 'instill sdk'                                                                                    |
| `<project: component>`               | Major service associated with this issue/PR. E.g., 'vdp: pipeline-backend', 'vdp: connector-backend' and 'model: model-backend'                                                                                                       |
| `feature`                            | New feature request                                                                                                                                                                                                                   |
| `improvement`                        | Enhancement of existing features                                                                                                                                                                                                      |
| `bug`                                | Issue indicating malfunction                                                                                                                                                                                                          |
| `duplicate`                          | Duplicate issue/PR already exists                                                                                                                                                                                                     |
| `stale`                              | Issue/PR open with no activity for too long                                                                                                                                                                                           |
| `wontfix`                            | Issue will not be worked on                                                                                                                                                                                                           |
| `priority: critical`                 | Issue causing a major outage or disruption for all users without any known workaround. The issue must be fixed immediately, taking precedence over other work. Should receive updates at least once per day.                          |
| `priority: high`                     | Issue important to a large percentage of users, with a workaround. Issues that are significantly ugly or painful, especially first-use or install-time issues. Issues with workarounds that would otherwise be ` priority: critical`. |
| `priority: medium`                   | Issue relevant to core functions, but not impeding progress. Important, but not urgent.                                                                                                                                               |
| `priority: low`                      | Relatively minor issue not relevant to core functions or only affecting user experience. Good-to-have changes/fixes, but not necessary.                                                                                               |

### Status Labels

These labels will help in planing and tracking active development activities for a issue/PR:

| Label     | Indicates that                                         |
| --------- | ------------------------------------------------------ |
| `linear`  | Issue/PR fully triaged and moved to the Plan stage     |
| `roadmap` | Issue/PR added to the roadmap with a clear target date |
