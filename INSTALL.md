# Configuration of production CI/CD environment

We use multiple CIs to take advantage of most developed infrastructure for each
operating system. Configuration files can be found below:

* [CirrusCI](.cirrus.yml) for Linux and OSX;
* [AppVeyor](appveyor.yml) for Windows (because it's faster);

## Production environment

Firebase functions need access to email account. Email and password can be set
via Cloud Functions config (also possible to separate Debug and Release GCP
projects):

```shell
$ firebase -P project-name functions:config:set \
    'email.service=gmail' \
    'email.auth.pass=my_secret_password' \
    'email.auth.user=myemail@gmail.com'
```

Note that, due to the authentication mechanism used (PLAIN), you will most
likely need to enable access to this Google Account for "less secure apps" at
https://myaccount.google.com/lesssecureapps.

Sometimes your account may be locked out if it's being accessed from a very
remote geographical location. Visit https://g.co/allowaccess to fix it and
then retry sending email.

## Build

We build on all major operating systems (Linux, OSX, Windows) to make sure that
developers are free to choose the one they prefer. We deploy only from Linux for
Android and OSX for iOS, because deploying Android from Windows would be
redundant.

Every Pull Request is built before it can be merged. Pull Requests may come from
external contributors, therefore Build phase does not have access to secret
keys. All our dependencies are public and pulled from public external resources.

There are 3 items that stand out (but not considered secret):

 - CodeCov coverage reporting tool;
 - `google-services.json` and `GoogleService-Info.plist` from the Debug Firebase
   project are included to make the application build;
 - `debug.keystore` is included to sign the application for access to the Debug
   Firebase project.

## Deploy

We deploy multiple artifacts to different services, and each of them requires
a Release build before being deployed.

### Build Android app, publish to Google Play

Building Android app for release requires two artifacts:

 - `google-services.json` and `GoogleService-Info.plist` from the Release
   Firebase are checked in at `app/src/release`;

 - upload key to sign the app for access to the Release Firebase project is
   stored in `ANDROID_KEYSTORE_DATA` secret environment variable
   (base64-encoded).

A new key can be generated with `keytool`. Use the following argument:
`-dname 'CN=dasfoo.org, OU=IT, O=DasFoo, L=Zurich, S=ZH, C=CH'`.

Publishing the app to Google Play requires a GCloud (GCP) Service Account.

Accessing Play Developer API requires a special Google Cloud project, see
[docs](https://developers.google.com/android-publisher/getting_started) for how
to set it up. The project is called "Google Play Android Developer".

Any service account on GCP can be used to access API, but for simplicity we pick
an account from the same project. You can pick an existing or create a new one
on the
[Service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
page. On the same page, you can create any number of keys anytime for the same
account, in case you need to debug it from your workstation. One of the keys has
to be stored in JSON format in `GOOGLE_APPLICATION_CREDENTIALS_DATA` environment
variable.

This service account has to be given "Release manager" role on the
"Settings > Users & permissions" page of
[Google Play Console](https://play.google.com/apps/publish/).

### Deploy AppEngine (for cron jobs)

We reuse the same account as for publishing to Google Play, to deploy AppEngine
code. To deploy to AppEngine, it has to be given "App Engine Deployer" role on
the [IAM page](https://console.cloud.google.com/iam-admin/iam) of GCP project(s)
that we deploy to (Debug and Release).

In addition, for the project that the service accounts belongs to, enable the
following APIs:

- [Google Service Management API](https://console.developers.google.com/apis/api/servicemanagement.googleapis.com/)
- [Google App Engine Admin API](https://console.developers.google.com/apis/api/appengine.googleapis.com/)

### Build iOS app and publish to App Store

Building a release version of iOS app requires signing it, similar to how it is
done for Android. However, the signing mechanism is different. We use
[match](https://docs.fastlane.tools/actions/match/) to store the keys in a Git
repository, on Cloud Source Repositories.

We reuse the same account as for publishing to Google Play, to download the
repository. For that, the account has to be given "Source Repository Reader"
role at the
[Repository Permissions](https://source.cloud.google.com/admin/permissions)
page. The repository may belong to the same Play-enabled GCP project. The Clone
URL of the repository has to be in `MATCH_GIT_URL` environment variable.

The repository contains encrypted keys, which have to be decrypted with a
password stored in `MATCH_PASSWORD` environment variable.

One the app is signed, it is published to App Store. We use a separate Apple
account (which does not have to be a Developer enabled account). The credentials
to this account are stored in `FASTLANE_USER` and `FASTLANE_PASSWORD`
environment variables.

### Deploy Website, Security Rules and Cloud Functions

The website is hosted on Firebase, and we use `firebase` command line tool to
deploy it, along with the rest of Firebase artifacts. Until Service Accounts are
[supported](https://github.com/firebase/firebase-tools/issues/787) by Firebase
CLI, we have to generate a token via `firebase login:ci` and store it in
`FIREBASE_TOKEN` environment variable. See
[Firebase](https://github.com/firebase/firebase-tools#using-with-ci-systems)
documentation for up-to-date information.
