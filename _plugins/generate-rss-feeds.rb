# This script create product pages for the website.

require 'jekyll'

module RssFeed

  def self.site_url(site, path)
    "#{site.config['url']}#{path}"
  end

  class ProductFeedsGenerator < Jekyll::Generator
    safe true
    priority :lowest

    TOPIC = "RSS feeds:"

    def generate(site)
      @site = site
      start = Time.now
      Jekyll.logger.info TOPIC, "Generating..."

      products = site.pages.select { |page| page.data['layout'] == 'product' }
      products.each do |product|
        site.pages << ProductFeed.new(site, product)
      end

      Jekyll.logger.info TOPIC, "Done in #{(Time.now - start).round(3)} seconds."
    end
  end

  class ProductFeed < Jekyll::Page
      def initialize(site, product)
        @site = site
        @base = site.source
        @dir = ""
        @name = "#{product.data['id']}.atom"

        events = []
        product.data['releases'].each do |release|
          release_name = release['releaseCycle']
          release_label = release['label']

          release_date = release['releaseDate']
          events << {
            "type" => "release",
            "release_name" => release_name,
            "release_label" => release_label,
            "date" => release_date,
          }

          eoas_date = release['eoas']
          if eoas_date && eoas_date.is_a?(Date) then
            events << {
              "type" => "eoas",
              "release_name" => release_name,
              "release_label" => release_label,
              "date" => eoas_date,
            }
          end

          eol_date = release['eol']
          if eol_date && eol_date.is_a?(Date) then
            events << {
              "type" => "eol",
              "release_name" => release_name,
              "release_label" => release_label,
              "date" => eol_date,
            }

            eol_date_7d = release['eol'] - 7
            events << {
              "type" => "eol-7d",
              "release_name" => release_name,
              "release_label" => release_label,
              "date" => eol_date_7d,
            }
          end

          eoes_date = release['eoes']
          if eoes_date && eoes_date.is_a?(Date) then
            events << {
              "type" => "eoes",
              "release_name" => release_name,
              "release_label" => release_label,
              "date" => eoes_date,
            }
          end
        end

        @data = {
          "layout" => "product-rss",
          "product_id" => product.data['id'],
          "product_label" => product.data['title'],
          "product_link" => RssFeed.site_url(site, product.data['permalink']),
          "events" => events.select { |event| event["date"] <= Date.today }.sort_by! { |event| event["date"] },
          "nav_exclude"=> true
        }

        self.process(@name)
      end
    end
end
