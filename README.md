# Templateer

Templateer is a minimal wrapper around [mruby-erb](https://github.com/jbreeden/mruby-erb.git) and [mruby-yaml](https://github.com/AndrewBelt/mruby-yaml.git) using the [go-mruby](https://github.com/mitchellh/go-mruby) bindings. It enables you to read json or yaml input and populate an erb template with it.

It is intended t be used in conjunction with other tools to provide the json or yaml data (e.g. `etcdctl`, `consul`, web services or manually written config). 

Watch behaviour similar to `confd` should be possible using these external tools but I haven't played with that. A PR (or an issue if it's not possible) with examples would be appreciated if it works!

# Usage
Usage is pretty simple: `templateer --data some_json_or_yaml_file --erb some_erb_file`

See the examples directory for examples of templates.

# Plans
I don't want to scope creep too much as the premise of the tool is really do one thing well.

Support *may* be added for the following:
- Producing several output files from a single run
- Encode json / yaml

# Building
You will need docker, Go 1.6+, make and govendor installed.
Note that the actual build happens in a docker container so no other host deps should be required.

```
go get -d github.com/mikesimons/go-mruby
govendor update github.com/mikesimons/go-mruby
make
```

# License
License is standard MIT. See LICENSE.md for specifics.
