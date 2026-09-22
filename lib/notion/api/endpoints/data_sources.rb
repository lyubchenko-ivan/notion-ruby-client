# frozen_string_literal: true

module Notion
  module Api
    module Endpoints
      module DataSources
        #
        # Gets a paginated array of Page objects contained in the requested data source,
        # filtered and ordered according to the filter and sort objects provided in the request.
        #
        # Starting with Notion-Version 2025-09-03, databases can contain multiple data
        # sources. Querying is done against a data source, not the database itself.
        # Use #database to look up a database's data source ids.
        #
        # @option options [id] :data_source_id
        #   Data source to query.
        #
        # @option options [Object] :filter
        #   When supplied, limits which pages are returned based on the provided criteria.
        #
        # @option options [[Object]] :sorts
        #   When supplied, sorts the results based on the provided criteria.
        #
        # @option options [UUID] :start_cursor
        #   Paginate through collections of data by setting the cursor parameter
        #   to a start_cursor attribute returned by a previous request's next_cursor.
        #   Default value fetches the first "page" of the collection.
        #   See pagination for more detail.
        #
        # @option options [integer] :page_size
        #   The number of items from the full list desired in the response. Maximum: 100
        def data_source_query(options = {})
          throw ArgumentError.new('Required arguments :data_source_id missing') if options[:data_source_id].nil?
          if block_given?
            Pagination::Cursor.new(self, :data_source_query, options).each do |page|
              yield page
            end
          else
            data_source_id = options.delete(:data_source_id)
            post("data_sources/#{data_source_id}/query", options)
          end
        end

        #
        # Adds a new data source to an existing database.
        #
        # @option options [Object] :parent
        #   Parent of the data source, referencing an existing database via :database_id.
        #
        # @option options [Object] :properties
        #   Property schema of data source.
        #   The keys are the names of properties as they appear in Notion and the values are
        #   property schema objects. Each data source must have exactly one property schema
        #   object of type "title".
        #
        # @option options [Object] :title
        #   Title of this data source.
        def create_data_source(options = {})
          throw ArgumentError.new('Required arguments :parent.database_id missing') if options.dig(:parent, :database_id).nil?
          throw ArgumentError.new('Required arguments :properties missing') if options.dig(:properties).nil?
          post('data_sources', options)
        end

        #
        # Updates an existing data source as specified by the parameters.
        #
        # @option options [id] :data_source_id
        #   Data source to update.
        #
        # @option options [Object] :title
        #   Title of data source as it appears in Notion. An array of rich text objects.
        #   If omitted, the title will remain unchanged.
        #
        # @option options [Object] :properties
        #   Updates to the property schema of a data source.
        #   If updating an existing property, the keys are the names or IDs
        #   of the properties as they appear in Notion and the values
        #   are property schema objects. If adding a new property, the key is
        #   the name of the property and the value is a property schema object.
        def update_data_source(options = {})
          data_source_id = options.delete(:data_source_id)
          throw ArgumentError.new('Required arguments :data_source_id missing') if data_source_id.nil?
          patch("data_sources/#{data_source_id}", options)
        end

        #
        # Retrieves a Data source object using the ID specified in the request.
        #
        # Returns a 404 HTTP response if the data source doesn't exist, or if the bot
        # doesn't have access to the data source. Returns a 429 HTTP response if the
        # request exceeds Notion's Request limits.
        #
        # @option options [id] :data_source_id
        #   Data source to get info on.
        def data_source(options = {})
          throw ArgumentError.new('Required arguments :data_source_id missing') if options[:data_source_id].nil?
          get("data_sources/#{options[:data_source_id]}")
        end
      end
    end
  end
end
