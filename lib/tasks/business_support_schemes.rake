# This is a one-time task that can be deleted after it has been run
require 'gds_api/business_support_api'

include ActionView::Helpers::SanitizeHelper

# Provide our own save method so that we can override the base_path to be the
# same as the imported one (this prevents some base_path clashes)
def save_document(document, base_path)
  return false if !document.valid?

  document.update_type = 'major'

  presented_document = DocumentPresenter.new(document).to_json
  presented_links = DocumentLinksPresenter.new(document).to_json

  presented_document[:base_path] = base_path
  presented_document[:routes][0][:path] = base_path

  document.set_errors_on(document)

  Services.publishing_api.put_content(document.content_id, presented_document)
  Services.publishing_api.patch_links(document.content_id, presented_links)
rescue GdsApi::HTTPErrorResponse => e
  puts e.message
end

# Provide methods to clean up the source data prior to importing it - this
# includes transforming some facet values where they have changed
def clean_string(str)
  strip_tags(str).strip.presence
end

def clean_string_empty(str)
  strip_tags(str).strip
end

def compile_body(scheme_details)
  clean_string_empty(scheme_details['details']['body']) +
    "\n\n## How much you can get\n\n#{money_range(scheme_details['details']['min_value'], scheme_details['details']['max_value'])}" +
    "\n\n## What you can get\n\n#{clean_string_empty(scheme_details['details']['additional_information'])}" +
    "\n\n## Who it's for\n\n#{clean_string_empty(scheme_details['details']['eligibility'])}" +
    "\n\n## Maximum employees\n\n#{scheme_details['details']['max_employees']}" +
    "\n\n## How to apply\n\n#{clean_string_empty(scheme_details['details']['evaluation'])}" +
    "\n\n## Organiser\n\n#{clean_string_empty(scheme_details['details']['organiser'])}"
end

def money_format(amount)
  Money.new(amount * 100, 'GBP').format(no_cents_if_whole: true)
end

def money_range(min, max)
  if (min.nil? || min == 0) && (max.nil? || max == 0)
    ''
  elsif min.nil? || min == 0
    "Up to #{money_format(max)}"
  elsif max.nil? || max == 0
    "From #{money_format(min)}"
  else
    "#{money_format(min)} - #{money_format(max)}"
  end
end

def all_facet_options(facet)
  BusinessFinanceSupportScheme.new.facet_options(facet).map do |option|
    option[1]
  end
end

def translate_business_sizes(arr)
  return all_facet_options('business_sizes') if arr.empty?

  arr.map! do |element|
    case element
    when 'between-501-and-1000', 'over-1000'
      'over-500'
    when 'up-to-249'
      'between-10-and-249'
    else
      element
    end
  end

  arr.sort.uniq
end

def translate_business_stages(arr)
  return all_facet_options('business_stages') if arr.empty?

  arr.map! do |element|
    case element
    when 'pre-start'
      'not-yet-trading'
    when 'grow-and-sustain'
      'established'
    else
      element
    end
  end

  arr.sort.uniq
end

def translate_industries(arr)
  return all_facet_options('industries') if arr.empty?

  arr.map! do |element|
    case element
    when 'agriculture'
      'agriculture-and-food'
    when 'information-communication-and-media'
      'information-technology-digital-and-creative'
    when 'real-estate'
      'real-estate-and-property'
    when 'utilities'
      'utilities-providers'
    else
      element
    end
  end

  arr.sort.uniq
end

def translate_types_of_support(arr)
  return all_facet_options('types_of_support') if arr.empty?
  arr.sort.uniq
end

namespace :business_support_schemes do
  desc 'Import all business finance support schemes from business-support-api'
  task import_all: :environment do
    business_support_api = GdsApi::BusinessSupportApi.new(
      Plek.new.find('business-support-api')
    )
    all_schemes = business_support_api.schemes.to_hash['results']

    puts "Importing #{all_schemes.length} business finance support schemes"

    all_schemes.map do |scheme|
      scheme_slug = File.basename(scheme['id'], '.json')
      scheme_details = business_support_api.scheme(scheme_slug).to_hash
      document = BusinessFinanceSupportScheme.new(
        title: clean_string(scheme_details['title']),
        summary: clean_string(scheme_details['details']['short_description']) || '[There should be a meta description here]',
        body: compile_body(scheme_details),
        business_sizes: translate_business_sizes(scheme['business_sizes']),
        business_stages: translate_business_stages(scheme['stages']),
        continuation_link: clean_string(scheme_details['details']['continuation_link']),
        industries: translate_industries(scheme['sectors']),
        types_of_support: translate_types_of_support(scheme['support_types']),
        will_continue_on: clean_string(scheme_details['details']['will_continue_on'])
      )

      if save_document(document, "/business-finance-support/#{scheme_slug}")
        print '.'
      else
        puts "Error importing \"#{scheme_slug}\":"
        puts document.errors.full_messages
      end
    end

    puts ''
  end

  # To make testing easier by being able to delete all imported content
  desc 'Delete all imported business finance support schemes'
  task delete_all: :environment do
    all_schemes = Services.publishing_api.get_content_items(
      document_type: 'business_finance_support_scheme',
      fields: ['content_id'],
      per_page: 999999,
    ).to_hash['results']

    if all_schemes.empty?
      puts 'There are no business finance support schemes to delete'
    else
      puts "Deleting #{all_schemes.length} business finance support schemes"
      all_schemes.each do |scheme|
        BusinessFinanceSupportScheme.find(scheme['content_id']).discard
        print '.'
      end
      puts ''
    end
  end
end
