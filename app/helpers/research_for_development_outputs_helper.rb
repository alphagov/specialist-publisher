module ResearchForDevelopmentOutputsHelper
  ##
  # Only exists here - rather than in the finder schema - because
  # specialist-frontend won't allow us to suppress any metadata that's
  # present (unlike finder-frontend, which allows us to suppress with
  # +display_as_result_metadata+).
  #
  # FCDO still need to be able to record the value without it showing up
  # publicly (for now), and until we can add the ability to specialist-frontend
  # to selectively hide data (we only want "Peer reviewed" to show up when present
  # as 'unreviewed' means nothing), this is where the backend gets its values.
  #
  def review_status_options
    [
      ["Unreviewed",    "unreviewed"],
      ["Peer reviewed", "peer_reviewed"],
    ]
  end
end
