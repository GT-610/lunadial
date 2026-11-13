# F-Droid build recipe

Draft of the metadata file that belongs in the
[fdroiddata](https://gitlab.com/fdroid/fdroiddata) repository at
`metadata/com.gt610.lunadial.yml`. It mirrors that path here so the submission
can be kept in version control next to the code; nothing in the build reads it.

Submitting a release means copying this file into a fork of `fdroiddata`,
opening a merge request, and answering the reviewer's questions. The recipe is
only valid for a tag that exists upstream, so update `commit:` together with
`CurrentVersion`, `CurrentVersionCode` and the fastlane changelog for the same
version code.

Before submitting, the checklist from the F-Droid quick start guide must hold:

- every release has a tag (e.g. `v0.5.0`) matching `versionName`
- `fastlane/metadata/android/en-US/short_description.txt` is under 80 characters
- `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt` exists (max 500 characters)
- the app builds from source with the command-line SDK only, and every
  dependency is FOSS
