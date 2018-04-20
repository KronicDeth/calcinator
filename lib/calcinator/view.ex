defmodule Calcinator.View do
  @moduledoc """
  A view for `Calcinator.Resources`
  """

  # Types

  @type pagination :: map

  @typedoc """
  `pagination` or `nil` if no pagination
  """
  @type maybe_pagination :: nil | pagination

  @typedoc """
  The raw request params that need to be parsed for view options
  """
  @type params :: %{String.t() => term}

  @typedoc """
  Resource(s) related to resource through a relationship
  """
  @type related :: nil | struct | [struct]

  @typedoc """
  The subject that must be authorized to view the individual attributes in the view.
  """
  @type subject :: term

  @typedoc """
  A module that implements the `Calcinator.View` behaviour.
  """
  @type t :: module

  # Callbacks

  @doc """
  Rendered `related` iodata.
  """
  @callback get_related_resource(related, %{
              required(:calcinator) => Calcinator.t(),
              optional(:params) => params,
              optional(:related) => related,
              optional(:source) => struct
            }) :: iodata

  @doc """
  Renders list of `struct` with optional pagination and params and required calcinator. `base_uri` is required when
  `pagination` is present.  `calcinator` `t:Calcinator.t/0` `subject` is for view-level authorization of individual
  attributes, while `t:Calcinator.t/0` `resources_module` is whole is used to reconstruct the `"sort"` query parameters
  for the pagination links.
  """
  @callback index([struct], %{
              required(:calcinator) => Calcinator.t(),
              optional(:base_uri) => URI.t(),
              optional(:pagination) => maybe_pagination,
              optional(:params) => params
            }) :: iodata

  @doc """
  Renders the show iodata for the given `struct` and optional params and required calcinator.  The `t:Calcinator.t/0`
  `subject` is used for view-level authorization of invididual attributes.
  """
  @callback show(struct, %{required(:calcinator) => Calcinator.t(), optional(:params) => params}) :: iodata

  @doc """
  Renders [the relationship iodata](http://jsonapi.org/format/#fetching-relationships) for the given `related`.
  """
  @callback show_relationship(related, %{
              optional(:calcinator) => Calcinator.t(),
              optional(:params) => params,
              optional(:related) => related,
              optional(:source) => struct
            }) :: iodata
end
