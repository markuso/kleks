module.exports = [
  # show root
  { from: "/", to: "_show/index" }

  # static
  { from: "/static/*", to: "static/*" }

  # Spine adapter
  {
    from: "/spine-adapter/:type",
    to: "_update/spine_adapter_model",
    method: "POST"
  }

  {
    from: "/spine-adapter/:type/:id",
    to: "_update/spine_adapter_model/:id",
    method: "PUT"
  }

  {
    from: "/spine-adapter/:type/:id",
    to: "_update/spine_adapter_model/:id",
    method: "DELETE"
  }

  {
    from: "/spine-adapter/:type",
    # to: "_view/docs_by_type",
    # Using a list function to filter out large data attributes
    to: "_list/docs/docs_by_type",
    method: "GET",
    query: {
      startkey: [":type"],
      endkey: [":type", {}],
      include_docs: "true"
    }
  }

  {
    from: "/spine-adapter/:type/:id",
    to: "_view/docs_by_type",
    method: "GET",
    query: {
      startkey: [":type", ":id"],
      endkey: [":type", ":id", {}],
      include_docs: "true"
    }
  }

  # File attachments paths
  { from: '/file/:id/:filename', to: '../../:id/:filename' }

  # show color page
  { from: "/_color_samples", to: "_show/color_samples" }

  # catch all
  { from: "*", to: "_show/not_found" }
]
