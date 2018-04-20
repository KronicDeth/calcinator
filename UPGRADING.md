# Upgrading

## v6.0.0

`query_options[:page]` is no longer ignored when passed to `use Calcinator.Resources.Ecto.Repo`'s `list/1` by default.  To restore the old behavior change the paginator to `Calcinator.Resources.Ecto.Repo.Pagination.Ignore`:

```elixir
config :calcinator, Calcinator.Resources.Ecto.Repo, paginator: Calcinator.Resources.Ecto.Repo.Pagination.Ignore
```

`Calcinator.View` callbacks have changed: `optional(:subject)` has been removed from the options map and replaced with `required(:calcinator)`, which is the full `t:Calcinator.t/0`.

| < v6.0.0                                                                                                                                                             | >= v6.0.0                                                                                                                                                                      |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `get_related_resource(related, %{optional(:params) => params, optional(:related) => related, optional(:source) => struct, optional(:subject) => subject}) :: iodata` | `get_related_resource(related, %{required(:calcinator) => Calcinator.t(), optional(:params) => params, optional(:related) => related, optional(:source) => struct}) :: iodata` |
| `index([struct], %{optional(:base_uri) => URI.t, optional(:pagination) => maybe_pagination, optional(:params) => params, optional(:subject) => subject}) :: iodata`  | `index([struct], %{optional(:base_uri) => URI.t, required(:calcinator) => Calcinator.t(), optional(:pagination) => maybe_pagination, optional(:params) => params}) :: iodata`  |
| `show(struct, %{optional(:params) => params, optional(:subject) => subject}) :: iodata`                                                                              | `show(struct, %{required(:calcinator) => Calcinator.t(), optional(:params) => params}) :: iodata`                                                                              |
| `show_relationship(related, %{optional(:params) => params, optional(:related) => related, optional(:source) => struct, optional(:subject) => subject}) :: iodata`    | `show_relationship(related, %{required(:calcinator) => Calcinator.t(), optional(:params) => params, optional(:related) => related, optional(:source) => struct}) :: iodata`    |

**If you `use Calcinator.JaSerializer.PhoenixView`, no changes are necessary**, but if you implement `Calcinator.View` directly, you will need to get the subject with `options.calcinator.subject` instead of `options[:subject]`.

## v5.0.0

### `Calcinator.get/4` first argument

In order to support passing the entire `Calcinator.t` struct to `calcinator_resources` event callbacks in instrumenters (`Callback.Instrumenter`), `Calcinator.get/4` now requires a `Calcinator.t` for the first argument instead of the `Calcinator.Resources.t` module.

Before

```elixir
Calcinator.get(calcinator.resources_module, params, "id", query_options)
```

After

```elixir
Calcinator.get(calcinator, params, "id", query_options)
```

## v4.0.0

### `Calcinator.Resources.changeset/1,2` return types

In order to support preloading of associations as required by `Ecto.Changeset.put_assoc/3` for `many_to_many` association support, `Calcinator.Resources.changeset/1,2` may now access the backing store, which means an `{:error, :ownership}` can occur.  Instead of having the type of the callbacks be `Ecto.Changeset.t | {:error, reason}`, it is better to use a proper Either type and use `{:ok, Ecto.Changeset.t} | {:error, reason}`, so any callback that returned `Ecto.Changeset.t` before must now return `{:ok, Ecto.Changeset.t}`.

## v3.0.0

### `Calcinator.Resources.allow_sandbox_access/1` return types

`Calcinator.Resources.allow_sandbox_access/1` must now return `:ok | {:error, :sandbox_access_disallowed}`.  The previous `{:already, :allowed | :owner}` maps to `:ok` while `:not_found` maps to `{:error, :sandbox_access_disallowed}`.

#### `Calcinator` action returns

If you previously had total coverage for all return types from `Calcinator` actions, they now also return `{:error, :sandbox_access_disallowed}` and `{:error, :timeout}`.  Previously, instead of `{:error, :sandbox_access_disallowed}`, `:not_found` may been returned, but that was a bug that leaked an implementation detail from how `DBConnection.Ownership` works, so it was removed.

#### `Calcinator.Resources.delete` arguments

`Calcinator.Resources.delete` deletes a changeset instead of a resource struct to allow constraints to be added to the `Ecto.Changeset.t` so that database constraint errors are transformed to validation errors.  `Calcinator.delete` now takes, as a second argument, the `Calcinator.Resources.query_options`

If you used `use Calcinator.Resources.Ecto.Repo`, it now generates `delete/2` (instead of `delete/1`) that expects an `Ecto.Changeset.t` and `Calcinator.Resources.query_options` and calls `Calcinator.Resources.Ecto.Repo.delete/3`, which now expects a changeset instead of resource struct as the second argument and the query options as the third argument.

#### `Calcinator.Resources.query_options`

`:meta` is now a required key in `Calcinator.Resources.query_options` in order to allow `Calcinator.Meta.Beam` to be passed through for loopback chains.

`Calcinator.Meta.Beam.put_new_lazy/2` can be used to add the sandbox token to the meta only if its not already present.  It should be used in place of `Calcinator.Meta.Beam.put/2` whenever the pre-existing meta beam might need to be passed through.

