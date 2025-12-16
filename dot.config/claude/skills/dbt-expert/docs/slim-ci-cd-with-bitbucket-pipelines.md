---
title: "Slim CI/CD with Bitbucket Pipelines for dbt Core | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/slim-ci-cd-with-bitbucket-pipelines"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

Set up CI/CD with dbt Cloud

This blog is specifically tailored for dbt Core users. If you're using dbt Cloud and your Git provider doesn't have a native dbt Cloud integration (like BitBucket), follow the [Customizing CI/CD with custom pipelines guide](https://docs.getdbt.com/guides/custom-cicd-pipelines?step=3) to set up CI/CD.

Continuous Integration (CI) sets the system up to test everyone’s pull request before merging. Continuous Deployment (CD) deploys each approved change to production. “Slim CI” refers to running/testing only the changed code, [thereby saving compute](https://discourse.getdbt.com/t/how-we-sped-up-our-ci-runs-by-10x-using-slim-ci/2603). In summary, CI/CD automates dbt pipeline testing and deployment.

[dbt Cloud](https://www.getdbt.com/), a much beloved method of dbt deployment, [supports GitHub- and Gitlab-based CI/CD](https://blog.getdbt.com/adopting-ci-cd-with-dbt-cloud/) out of the box. It doesn’t support Bitbucket, AWS CodeCommit/CodeDeploy, or any number of other services, but you need not give up hope even if you are tethered to an unsupported platform.

Although this article uses Bitbucket Pipelines as the compute service and Bitbucket Downloads as the storage service, this article should serve as a blueprint for creating a dbt-based Slim CI/CD *anywhere*. The idea is always the same:

1. Deploy your product and save the deployment artifacts.
2. Use the artifacts to allow dbt to determine the stateful changes and run only those (thereby achieving “slimness”).

## Overview of steps[​](#overview-of-steps "Direct link to Overview of steps")

To accomplish this, we’ll need to prepare three parts of our pipeline to work together:

1. Database access - ensure that our warehouse has users, roles and permissions to run our pipelines
2. Repository preparation - setup our repository and build our automation based on our git platform provider’s (in this example, Bitbucket) capabilities
3. Bitbucket (or other platform) environment - configure our environment with the necessary secrets and variables to run our workflow

## Step 1: Database preparation[​](#step-1-database-preparation "Direct link to Step 1: Database preparation")

In general, we want the following:

1. Create a CI user with proper grants in your database, including the ability to create the schema(s) they’ll write to (`create on [dbname]`).
2. Create a production user with proper grants in your database.

The specifics will differ based on the database type you’re using. To see what constitutes “proper grants”, please consult the dbt Discourse classic “[The exact grant statements we use in a dbt project](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430)” and Matt Mazur’s “[Wrangling dbt Database Permissions](https://mattmazur.com/2018/06/12/wrangling-dbt-database-permissions/)”.

In my case, I created:

1. A `dev_ci` Postgres user which had been granted a previously created `role_dev` role (same as all other development users). `role_dev` has connect and create grants on the database.
2. A `dbt_bitbucket` user which has been granted a previously created `role_prod` role (same as dbt Cloud production environment). The `role_prod` role must have write access to your production schemas.

```
create role role_dev;

grant create on database [dbname] to role_dev;

-- Grant all permissions required for the development role

create role role_prod;

grant create on database [dbname] to role_prod;

-- Grant all permissions required for the production role

create role dev_ci with login password [password];

grant role_dev to dev_ci;

create schema dbt_ci;

grant all on schema dbt_ci to role_dev;

alter schema dbt_ci owner to role_dev;

create role dbt_bitbucket with login password [password];

grant role_prod to dbt_bitbucket;
```

### Role Masking[​](#role-masking "Direct link to Role Masking")

Finally - and this might be a Postgres-only step - I had to make sure that the regularly scheduled dbt Cloud jobs connected with a `dbt_cloud` user with a `role_prod` grant would be able to drop and re-create views and tables during their run, which they could not if `dbt_bitbucket` had previously created and owned them. To do that, I needed to [mask both roles](https://dba.stackexchange.com/a/295736):

```
alter role dbt_bitbucket set role role_prod;

alter role dbt_cloud set role role_prod;
```

That way, any tables and views created by either user would be owned by “user” role\_prod.

## Step 2: Repository preparation[​](#step-2-repository-preparation "Direct link to Step 2: Repository preparation")

Next, we’ll need to configure the repository. Within the repo, we’ll need to configure:

1. The pipeline environment
2. The database connections
3. The pipeline itself

### Pipeline environment: requirements.txt[​](#pipeline-environment-requirementstxt "Direct link to Pipeline environment: requirements.txt")

You’ll need at least your dbt adapter-specific package, ideally pinned to a version. Mine is just:

```
dbt-[adapter] ~= 1.0
```

### Database connections: profiles.yml[​](#database-connections-profilesyml "Direct link to Database connections: profiles.yml")

You shouldn’t ever commit secrets in a plain-text file, but you can reference environmental variables (which we’ll securely define in Step 3).

```
your_project:
  target: ci
  outputs:
    ci:
      type: postgres
      host: "{{ env_var('DB_CI_HOST') }}"
      port: "{{ env_var('DB_CI_PORT') | int }}"
      user: "{{ env_var('DB_CI_USER') }}"
      password: "{{ env_var('DB_CI_PWD') }}"
      dbname: "{{ env_var('DB_CI_DBNAME') }}"
      schema: "{{ env_var('DB_CI_SCHEMA') }}"
      threads: 16
      keepalives_idle: 0
    prod:
      type: postgres
      host: "{{ env_var('DB_PROD_HOST') }}"
      port: "{{ env_var('DB_PROD_PORT') | int }}"
      user: "{{ env_var('DB_PROD_USER') }}"
      password: "{{ env_var('DB_PROD_PWD') }}"
      dbname: "{{ env_var('DB_PROD_DBNAME') }}"
      schema: "{{ env_var('DB_PROD_SCHEMA') }}"
      threads: 16
      keepalives_idle: 0
```

### Pipeline itself: bitbucket-pipelines.yml[​](#pipeline-itself-bitbucket-pipelinesyml "Direct link to Pipeline itself: bitbucket-pipelines.yml")

This is where you’ll define the steps that your pipeline will take. In our case, we’ll use the Bitbucket Pipelines format, but the approach will be similar for other providers.

There are two pipelines we need to configure:

1. Continuous Deployment (CD) pipeline, which will deploy and also store the production run artifacts
2. Continuous Integration (CI) pipeline, which will retrieve them for state-aware testing runs in development

[The entire file is accessible in a Gist](https://gist.github.com/shippy/78c2f5b124b70f31b2cef81c9017c8fd), but we’ll take it step-by-step to explain what we’re doing and why.

### Continuous Deployment: Transform by latest master and keep the artifacts[​](#continuous-deployment-transform-by-latest-master-and-keep-the-artifacts "Direct link to Continuous Deployment: Transform by latest master and keep the artifacts")

Each pipeline is a speedrun of setting up the environment and the database connections, then running what needs to be run. In this case, we also save the artifacts to a place we can retrieve them from - here, it’s the Bitbucket Downloads service, but it could just as well be AWS S3 or another file storage service.

```
image: python:3.8

pipelines:
  branches:
    main:
      - step:
          name: Deploy to production
          caches:
            - pip
          artifacts:  # Save the dbt run artifacts for the next step (upload)
            - target/*.json
          script:
            - python -m pip install -r requirements.txt
            - mkdir ~/.dbt
            - cp .ci/profiles.yml ~/.dbt/profiles.yml
            - dbt deps
            - dbt seed --target prod
            - dbt run --target prod
            - dbt snapshot --target prod
      - step:
          name: Upload artifacts for slim CI runs
          script:
            - pipe: atlassian/bitbucket-upload-file:0.3.2
              variables:
                BITBUCKET_USERNAME: $BITBUCKET_USERNAME
                BITBUCKET_APP_PASSWORD: $BITBUCKET_APP_PASSWORD
                FILENAME: 'target/*.json'
```

Reading the file over, you can see that we:

1. Set the container image to Python 3.8
2. Specify that we want to execute the workflow on each change to the branch called main (if yours is called something different, you’ll want to change this)
3. Specify that this pipeline is a two-step process
4. Specify that in the first step called “Deploy to production”, we want to:
   1. Use whatever pip cache is available, if any
   2. Keep whatever JSON files are generated in this step in target/
   3. Run the dbt setup by first installing dbt as defined in requirements.txt, then adding `profiles.yml` to the location dbt expects them in, and finally running `dbt deps` to install any dbt packages
   4. Run `dbt seed`, `run`, and `snapshot`, all with `prod` as specified target
5. Specify that in the first step called “Upload artifacts for slim CI runs”, we want to use the Bitbucket “pipe” (pre-defined action) to authenticate with environment variables and upload all files that match the glob `target/*.json`.

In summary, anytime anything is pushed to main, we’ll ensure our production database reflects the dbt transformation, and we’ve saved the resulting artifacts to defer to.

> ❓ **What are artifacts and why should I defer to them?** dbt artifacts are metadata of the last run - what models and tests were defined, which ones ran successfully, and which failed. If a future dbt run is set to ***defer*** to this metadata, it means that it can select models and tests to run based on their state, including and especially their difference from the reference metadata. See [Artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts), [Selection methods: “state”](https://docs.getdbt.com/reference/node-selection/methods#state), and [Caveats to state comparison](https://docs.getdbt.com/reference/node-selection/state-comparison-caveats) for details.

### Slim Continuous Integration: Retrieve the artifacts and do a state-based run[​](#slim-continuous-integration-retrieve-the-artifacts-and-do-a-state-based-run "Direct link to Slim Continuous Integration: Retrieve the artifacts and do a state-based run")

The Slim CI pipeline looks similar to the CD pipeline, with a couple of differences explained in the code comments. As discussed earlier, it’s the deferral to the artifacts is that makes our CI run “slim”.

```
pipelines:
  pull-requests:
    '**':  # run on any branch that’s referenced by a pull request
      - step:
          name: Set up and build
          caches:
            - pip
          script:
            # Set up dbt environment + dbt packages. Rather than passing
            # profiles.yml to dbt commands explicitly, we'll store it where dbt
            # expects it:
            - python -m pip install -r requirements.txt
            - mkdir ~/.dbt
            - cp .ci/profiles.yml ~/.dbt/profiles.yml
            - dbt deps

            # The following step downloads dbt artifacts from the Bitbucket
            # Downloads, if available. (They are uploaded there by the CD
            # process -- see "Upload artifacts for slim CI runs" step above.)
            #
            # curl loop ends with "|| true" because we want downstream steps to
            # always run, even if the download fails. Running with "-L" to
            # follow the redirect to S3, -s to suppress output, --fail to avoid
            # outputting files if curl for whatever reason fails and confusing
            # the downstream conditions.
            #
            # ">-" converts newlines into spaces in a multiline YAML entry. This
            # does mean that individual bash commands have to be terminated with
            # a semicolon in order not to conflict with flow keywords (like
            # for-do-done or if-else-fi).
            - >-
              export API_ROOT="https://api.bitbucket.org/2.0/repositories/$BITBUCKET_REPO_FULL_NAME/downloads";
              mkdir target-deferred/;
              for file in manifest.json run_results.json; do
                curl -s -L --request GET \
                  -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
                  --url "$API_ROOT/$file" \
                  --fail --output target-deferred/$file;
              done || true
            - >-
              if [ -f target-deferred/manifest.json ]; then
                export DBT_FLAGS="--defer --state target-deferred/ --select +state:modified";
              else
                export DBT_FLAGS="";
              fi

            # Finally, run dbt commands with the appropriate flag that depends
            # on whether state deferral is available. (We're skipping `dbt
            # snapshot` because only production role can write to it and it's
            # not set up otherwise.)
            - dbt seed
            - dbt run $DBT_FLAGS
            - dbt test $DBT_FLAGS
```

In short, we:

1. Set up the pipeline trigger condition to trigger on any pull request
2. Set up dbt
3. Retrieve the files from Bitbucket Downloads via API and credentials
4. Set flags for state deferral if the retrieval was successful
5. Run dbt with the default target (which we’d defined in `profiles.yml` as `ci`)

## Step 3: Bitbucket environment preparation[​](#step-3-bitbucket-environment-preparation "Direct link to Step 3: Bitbucket environment preparation")

Finally, we need to setup the environment so that all the steps requiring authentication can succeed, this includes:

1. Database authentication - for dbt communicating with the warehouse
2. Bitbucket Downloads authentication - for storing our dbt artifacts

As with the earlier steps, these specific instructions are for Bitbucket but the basic principles apply to any other platform.

### Database authentication[​](#database-authentication "Direct link to Database authentication")

1. Determine the values of all of the variables in `.ci/profiles.yml` (`DB_{CI,PROD}_{HOST,PORT,USER,PWD,DBNAME,SCHEMA}`)
2. Go to Repository > Repository Settings > Repository Variables in Bitbucket and define them there, making sure to store any confidential values as “Secured”.

![Bitbucket repository variables settings screenshot](https://docs.getdbt.com/assets/images/2022-04-14-add-ci-cd-to-bitbucket-image-2-ff36801cf6ae9f2e40367b02502ae855.png)

### Bitbucket Downloads authentication[​](#bitbucket-downloads-authentication "Direct link to Bitbucket Downloads authentication")

1. Go to Personal Settings > App Passwords in Bitbucket and create a Bitbucket App Password with scope `repository:write`.
2. Go to Repository > Repository Settings > Repository Variables and define the following:
   1. `BITBUCKET_USERNAME`, which is not your sign-up e-mail, but rather the username found by clicking your avatar in the top left > Personal settings > Account settings page, under Bitbucket Profile Settings.
   2. `BITBUCKET_APP_PASSWORD`, making sure to store it as “Secured”

![Bitbucket repository app password scope settings screenshot](https://docs.getdbt.com/assets/images/2022-04-14-add-ci-cd-to-bitbucket-image-1-9f1984dc3459097fd154c7800ac23a45.png)

### Enable Bitbucket Pipelines[​](#enable-bitbucket-pipelines "Direct link to Enable Bitbucket Pipelines")

Lastly, under Repository > Repository Settings > Pipelines Settings, check “Enable Pipelines”.

![Bitbucket Pipeline Settings enabling screenshot](data:image/png;base64,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)

## Step 4: Test[​](#step-4-test "Direct link to Step 4: Test")

You’re all done! Now it’s time to test that things work:

1. Push a change to your main branch. This should trigger a Pipeline. Check that it’s successful.
2. File a Pull Request with a change to a single model / addition of a single test. Check that only that model/test ran.

## Conclusion[​](#conclusion "Direct link to Conclusion")

It’s important to remember that CI/CD is a convenience, not a panacea. You must still devise the model logic and determine the appropriate tests. Some things it can do, though: catch more mistakes early, make sure that the database always reflects the most up-to-date code, and decrease the friction in collaboration. By automating the steps that should *always* be taken, it frees you up to think about the unusual steps required (e.g., do your changes to [incremental models](https://docs.getdbt.com/docs/build/incremental-models) require an additional deployment with `--full-refresh`?) and reduces the amount of review that others’ actions necessitate.

Plus, it’s a good time, and it’s fun to watch the test lights turn green. Ding!

![wild-child-yes.gif](https://c.tenor.com/wemr0g_Do8IAAAAC/wild-child-yes.gif)

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

COALESCE SQL function: Why we love it](https://docs.getdbt.com/blog/coalesce-sql-love-letter)[Older post

Making dbt Cloud API calls using dbt-cloud-cli](https://docs.getdbt.com/blog/making-dbt-cloud-api-calls-using-dbt-cloud-cli)
