# Contributing to PB Attendence Tracker App

Thank you for considering contributing! We welcome bug reports, feature requests, documentation improvements, and code contributions. This guide explains how to contribute in a way that makes reviews faster and merges smoother.

Table of contents
- [How can I contribute?](#how-can-i-contribute)
- [Reporting bugs](#reporting-bugs)
- [Suggesting enhancements](#suggesting-enhancements)
- [Code contribution workflow (PR)](#code-contribution-workflow-pr)
- [Branching and commits](#branching-and-commits)
- [Style, tests, and reviews](#style-tests-and-reviews)
- [Community and communication](#community-and-communication)
- [Contributor license and legal](#contributor-license-and-legal)

## How can I contribute?
- Open an issue for a bug or feature request.
- Fork the repo, implement your changes, and open a pull request (PR).
- Improve docs, add examples, or fix typos — documentation improvements are great first contributions.

## Reporting bugs
When opening a bug report, include:
- A clear, descriptive title.
- Steps to reproduce the behavior.
- Expected and actual behavior.
- Screenshots, error messages, and stack traces (if applicable).
- Environment (OS, Node/Python version, DB, repo commit SHA).

Use the issue template if one is available.

## Suggesting enhancements
For feature requests:
- Explain the problem the feature solves.
- Describe the desired API, UI flow, or data model.
- Share alternatives you considered.
- If you can, propose a small plan or outline for implementation.

## Code contribution workflow (PR)
1. Fork the repository and clone your fork.
2. Create a branch for your change:
   git checkout -b feat/short-description or fix/short-description
3. Make your changes in that branch. Keep changes small and focused.
4. Run tests and linters locally.
5. Commit your changes with clear messages (see below).
6. Push your branch to your fork and open a PR against `main` (or the repository's default branch).
7. Fill the PR template (if present), add related issue number with `Fixes #<issue>` when appropriate.
8. Address review comments and update the PR until approved.

A reviewer will review, request changes, or merge. Large features may be split into multiple PRs.

## Branching and commits
- Branch naming: use one of these prefixes:
  - feat/ — new feature
  - fix/ — bug fix
  - docs/ — documentation-only changes
  - chore/ — maintenance tasks
  - test/ — tests related
- Commit messages: follow Conventional Commits style for clarity.
  - Examples:
    - feat(auth): add JWT refresh token endpoint
    - fix(api): correct user serialization in session endpoint
    - docs: update README installation steps

- Keep commits atomic and focused. Squash or rebase before merge if requested by maintainers.

## Style, tests, and reviews
- Follow the project's code style (ESLint/Prettier for JS/TS, black/flake8 for Python). Configure your editor with the repo's settings.
- Add tests for bug fixes and new features. Maintain or increase test coverage.
- Run the full test suite and linters before submitting a PR.
- Include changelog/release notes information if your change affects public behavior.

Suggested commands (replace with actual project commands):
- Install deps: npm install | pip install -r requirements.txt
- Run tests: npm test | pytest
- Lint: npm run lint | flake8
- Format: npm run format | black .

## Pull request checklist
Before you request a review, ensure:
- [ ] The PR is linked to an issue (if applicable).
- [ ] Tests pass locally.
- [ ] New code is covered by tests.
- [ ] Linting and formatting are applied.
- [ ] You followed commit message and branch naming guidelines.
- [ ] Documentation updated (README, docs, comments) where necessary.

## Community and communication
- Be respectful and patient in discussions.
- For major changes, open an issue first to discuss design and scope.
- Use issues for tracking and PRs for proposed changes.

## Contributor license and legal
By contributing, you agree your contributions will be made under the project's license. If the project uses a Contributor License Agreement (CLA), follow the instructions (we will indicate here if a CLA is required).

---

Thanks for helping improve PB Attendence Tracker App! If you'd like, I can also:
- create PR templates / ISSUE templates,
- add GitHub Actions CI workflow examples,
- or tailor these guidelines to an exact stack and test commands — tell me the stack and scripts and I’ll update both files accordingly.
