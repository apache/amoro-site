<!--
  - Licensed to the Apache Software Foundation (ASF) under one
  - or more contributor license agreements.  See the NOTICE file
  - distributed with this work for additional information
  - regarding copyright ownership.  The ASF licenses this file
  - to you under the Apache License, Version 2.0 (the
  - "License"); you may not use this file except in compliance
  - with the License.  You may obtain a copy of the License at
  -
  -   http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing,
  - software distributed under the License is distributed on an
  - "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  - KIND, either express or implied.  See the License for the
  - specific language governing permissions and limitations
  - under the License.
  -->

# Arctic Documentation Site

This repository contains the documentation for [Arctic](https://github.com/NetEase/arctic).
It's built with [Hugo](https://gohugo.io/) and hosted at https://arctic.netease.com.

# Structure

The Arctic documentation site is actually constructed from two hugo sites. The first, is the site page. The second site, 
is the documentation site which contains the full Arctic documentation. The site page and
documentation sites are completely self-contained in the `./arctic-site` and `./arctic-docs` directories, respectively.

## Relationship to the Arctic Repository

All markdown pages that are specific to an Arctic version are maintained in the Arctic repository. All pages common across all version
releases are kept here in the Arctic-docs repo.

`NetEase/arctic`
- The `docs` folder in the [Arctic repository](https://github.com/NetEase/arctic) contains all the markdown docs used by the **versioned** docs site.

`NetEase/arctic-docs`
- The `arctic-docs/content/docs` folder is the target folder when copying the docs over during a version release
- The `arctic-site/content/common` folder is where you can find the common markdown files shared across all versions

During each new release, the release manager will:
1. Create a branch in this repo from main named for the release version
2. Copy the contents under `docs` in the iceberg repo to `./arctic-docs/content/docs` in the **release** branch
3. Update the latest branch HEAD to point to the release branch HEAD

# How to Contribute

## Submitting Pull Requests

Changes to the markdown contents for **version** specific pages should be submitted directly in the Iceberg repository.

Changes to the markdown contents for common pages should be submitted to this repository against the `main` branch.

Changes to the website appearance (e.g. HTML, CSS changes) should be submitted to this repository against the `main` branch.

Changes to the documentation of old Iceberg versions should be submitted to this repository against the specific version branch.

In summary, you can open a PR against where you find the related markdown file. With the exception of `spec.md`, there are no duplicate
markdown files between the `master` branch in the iceberg repo and the `main` branch in the iceberg-docs repo. For changes to `spec.md`,
PRs should be opened against the iceberg repo, not the iceberg-docs repo.

## Reporting Issues

All issues related to the doc website should still be submitted to the [Arctic repository](https://github.com/NetEase/arctic).
The GitHub Issues feature of this repository is disabled.

## Running Locally

Clone this repository to run the website locally:
```shell
git clone git@github.com:NetEase/arctic-docs.git
cd arctic-docs
```

To start the site page site locally, run:
```shell
(cd arctic-site && hugo serve)
```

To start the documentation site locally, run:
```shell
(cd arctic-docs && hugo serve)
```

If you would like to see how the latest website looks based on the documentation in the Iceberg repository, you can copy docs to this repository by:
```shell
rm -rf arctic-docs/content/docs
cp -r <path to arctic repo>/docs docs/content/docs
```

## Scanning For Broken Links

If you'd like to scan for broken links, one available tool is linkcheck that can be found [here](https://github.com/filiph/linkcheck).

# How the Website is Deployed

## Testing Both Sites Locally

In some cases, it's useful to test both the landing-page site and the docs site locally. Especially in situations
where you need to test relative links between the two sites. This can be achieved by building both sites with custom
`baseURL` and `publishDir` values passed to the CLI. You can then run the site with any local live server, such as the
[Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension for VSCode.

First, change into the `arctic-site` directory and build the site. Use `-b` and `-d` to set `baseURL` and `publishDir`, respectively.
```
cd arctic-site
hugo -b http://localhost:5500/ -d ../public
```

Next, change into the `arctic-docs` directory and do the same thing. Remember that the docs-site is deployed to a `docs/<VERSION>` url, relative to the landing-page site. Since the landing-page was deployed to `../publish` in the example
above, the example below usees `../public/docs/latest` to deploy a `latest` version docs-site.
```
cd ../arctic-docs
hugo -b http://localhost:5500/docs/latest/ -d ../public/docs/latest
```

You should then have both sites deployed to the `public` directory which you can launch using your live server.

**Note:** The examples above use port `5500`. Be sure to change the port number if your local live server uses a different port.