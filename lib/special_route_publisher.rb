require 'gds_api/publishing_api/special_route_publisher'

class SpecialRoutePublisher
  def initialize(publisher_options)
    @publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(publisher_options)
  end

  def publish(route)
    payload = route.merge(
      format: "special_route",
      publishing_app: "finder-frontend",
      rendering_app: "finder-frontend",
      type: route_type,
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
    )

    @publisher.publish(payload)
  rescue GdsApi::TimedOutException
    puts "WARNING: publishing-api timed out when trying to publish route #{payload.inspect}"
  rescue GdsApi::HTTPServerError => e
    puts "WARNING: publishing-api errored out when trying to publish route #{payload.inspect}\n\nError: #{e.inspect}"
  end

  def self.routes
    [
      {
        content_id: "9f306cd5-1842-43e9-8408-2c13116f4717",
        base_path: "/test-search/search",
        title: "GOV.UK search results API",
        description: "Sitewide search results are displayed in JSON format here.",
        type: 'exact',
      },
      {
        content_id: "9f306cd5-1842-43e9-8408-2c13116f4717",
        base_path: "/test-search/search.json",
        title: "GOV.UK search results API",
        description: "Sitewide search results are displayed in JSON format here.",
        type: 'exact',
      }
    ]
  end
end
