# frozen_string_literal: true

module Notion
  module Api
    module Endpoints
      module Databases
        #
        # Gets a paginated array of Page object s contained in the requested database,
        # filtered and ordered according to the filter and sort objects provided in the request.
        #
        # Filters are similar to the filters provided in the Notion UI. Filters operate
        # on database properties and can be combined. If no filter is provided, all the
        # pages in the database will be returned with pagination.
        #
        # Sorts are similar to the sorts provided in the Notion UI. Sorts operate on
        # database properties and can be combined. The order of the sorts in the request
        # matter, with earlier sorts taking precedence over later ones.
        #
        # @deprecated As of Notion-Version 2025-09-03, databases can hold multiple data
        #   sources, and querying is performed against a data source id, not a database
        #   id. Use {#data_source_query} instead, resolving the data source id via
        #   {#database}'s :data_sources field.
        #
        # @option options [id] :database_id
        #   Database to query.
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
        def database_query(options = {})
          throw ArgumentError.new('Required arguments :database_id missing') if options[:database_id].nil?
          logger.warn('[DEPRECATED] #database_query is deprecated as of Notion-Version 2025-09-03 ' \
                      'and only works for databases with a single data source. Use #data_source_query instead.')
          if block_given?
            Pagination::Cursor.new(self, :database_query, options).each do |page|
              yield page
            end
          else
            database_id = options.delete(:database_id)
            post("databases/#{database_id}/query", options)
          end
        end

        #
        # Creates a new database, with a single data source, in the specified page.
        #
        # As of Notion-Version 2025-09-03, the property schema is nested under
        # :initial_data_source instead of being a top-level :properties argument. For
        # convenience, a top-level :properties option is still accepted here and is
        # wrapped into :initial_data_source automatically.
        #
        # @option options [Object] :parent
        #   Parent of the database, which is always going to be a page.
        #
        # @option options [Object] :title
        #   Title of this database.
        #
        # @option options [Object] :initial_data_source
        #   The initial data source for this database, e.g. { properties: { ... } }.
        #
        # @option options [Object] :properties
        #   Shorthand for initial_data_source[:properties]. Property schema of the
        #   database's initial data source.
        #   The keys are the names of properties as they appear in Notion and the values are
        #   property schema objects. Property Schema Object is a metadata that controls
        #   how a database property behaves, e.g. {"checkbox": {}}.
        #   Each database must have exactly one database property schema object of type "title".
        def create_database(options = {})
          throw ArgumentError.new('Required arguments :parent.page_id missing') if options.dig(:parent, :page_id).nil?
          throw ArgumentError.new('Required arguments :title missing') if options.dig(:title).nil?

          properties = options.delete(:properties)
          if options[:initial_data_source].nil?
            throw ArgumentError.new('Required arguments :properties missing') if properties.nil?

            options[:initial_data_source] = { properties: properties }
          end

          post('databases', options)
        end

        #
        # Updates an existing database as specified by the parameters.
        #
        # As of Notion-Version 2025-09-03, this endpoint only accepts database-level
        # fields (:title, :description, :icon, :cover, :is_inline, :in_trash,
        # :is_locked, :parent). Updating a :properties schema is now done per data
        # source via {#update_data_source}.
        #
        # @option options [id] :database_id
        #   Database to update.
        #
        # @option options [Object] :title
        #   Title of database as it appears in Notion. An array of rich text objects.
        #   If omitted, the database title will remain unchanged.
        #
        def update_database(options = {})
          database_id = options.delete(:database_id)
          throw ArgumentError.new('Required arguments :database_id missing') if database_id.nil?
          patch("databases/#{database_id}", options)
        end

        #
        # Retrieves a Database object using the ID specified in the request.
        #
        # Returns a 404 HTTP response if the database doesn't exist, or if the bot
        # doesn't have access to the database. Returns a 429 HTTP response if the
        # request exceeds Notion's Request limits.
        #
        # As of Notion-Version 2025-09-03, the response's :data_sources field lists
        # the data source ids and names that belong to this database, for use with
        # {#data_source_query}, {#data_source} and {#update_data_source}.
        #
        # @option options [id] :database_id
        #   Database to get info on.
        def database(options = {})
          throw ArgumentError.new('Required arguments :database_id missing') if options[:database_id].nil?
          get("databases/#{options[:database_id]}")
        end
      end
    end
  end
end