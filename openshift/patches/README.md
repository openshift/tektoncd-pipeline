This is a collection of temporary patches to apply when we don't have any other
choices than to having it directly upstream. You really should think twice
before you add a patch of the consequences and the pain to maintain it. This may
be the easy way now to get the CI green but you do end up in a world of pain in
the near future trying to maintain it.

Having said that! If you want a patch, you need to use git
[format-patch](https://git-scm.com/docs/git-format-patch) and add it in here it
should be applied when you (or nightly job) run the update-to-head.

Make sure you add a proper commit message before launching the format message
since we want to track the reason why this patch was needed.
