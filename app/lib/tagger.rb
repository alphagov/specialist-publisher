require "services"

class Tagger
  def self.add_tags(content_id, do_tag: true, &block)
    new.add_tags(content_id, do_tag:, &block)
  end

  def add_tags(content_id, do_tag: true)
    existing_taxon_ids, version = fetch_existing_taxons(content_id)
    new_taxon_ids = (yield existing_taxon_ids).uniq
    return false if no_change_in_taxons?(existing_taxon_ids, new_taxon_ids)

    tag(content_id, new_taxon_ids, version) if do_tag
    true
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException
    retries ||= 0
    retry if (retries += 1) < 3
    raise
  rescue GdsApi::HTTPNotFound
    Rails.logger.warn("Cannot find content item '#{content_id}' in the publishing api")
  end

private

  def no_change_in_taxons?(existing_taxon_ids, new_taxon_ids)
    existing_taxon_ids.sort == new_taxon_ids.sort
  end

  def tag(content_id, taxon_ids, version)
    Services.publishing_api.patch_links(
      content_id,
      links: { taxons: taxon_ids },
      previous_version: version,
      bulk_publishing: true,
    )
  end

  def fetch_existing_taxons(content_id)
    link_content = Services.publishing_api.get_links(content_id)
    version = link_content["version"]
    taxons = link_content.dig("links", "taxons") || []
    [taxons, version]
  end
end
