if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Calcinator.Controller.Error.Plug do
    @moduledoc """
    Allows to configure options for `Calcinator.Controller.Error`

    `Calciantor.Controller.Error.render_changeset_error/2` can be customized to use the `render_changeset_error`
    options when calling `Calcinator.Controller.Error.render_changeset_error/3`.

        ecto_schema_module = Notes.Notes.Note
        embedded_attribute_set = MapSet.new(~w(author recipients)a)

        render_changeset_error_options =
        ecto_schema_module
        |> ancestor_descendants_from_ecto_changeset_path_options_from_ecto_schema_module()
        |> update_in([:association_set], &MapSet.difference(&1, embedded_attribute_set))
        |> update_in([:attribute_set], &MapSet.union(&1, embedded_attribute_set))

        plug(Calcinator.Controller.Error.Plug, render_changeset_error: render_changeset_error_options)

    """

    import Plug.Conn

    @behaviour Plug

    @impl Plug
    def call(conn, configuration) do
      put_private(conn, Calcinator.Controller.Error, configuration)
    end

    @impl Plug
    def init(configuration) do
      configuration
    end
  end
end
