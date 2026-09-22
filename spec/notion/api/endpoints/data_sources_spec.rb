# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Notion::Api::Endpoints::DataSources do
  let(:client) { Notion::Client.new }
  let(:data_source_id) { '6a91c56ebc5e46699e34952e09ec53c0' }
  let(:database_id) { '6a91c56ebc5e46699e34952e09ec53c0' }
  let(:title) do
    [
      {
        "text": {
          "content": 'Orbit 💜 Notion'
        }
      }
    ]
  end
  let(:properties) do
    {
      "Name": {
        "title": {}
      }
    }
  end

  context 'data sources' do
    it 'queries', vcr: { cassette_name: 'data_source_query' } do
      response = client.data_source_query(data_source_id: data_source_id)
      expect(response.results.length).to be >= 1
    end

    it 'paginated queries', vcr: { cassette_name: 'paginated_data_source_query' } do
      pages = []
      client.data_source_query(data_source_id: data_source_id, page_size: 1) do |page|
        pages.concat page.results
      end
      expect(pages.size).to be >= 1
    end

    it 'creates', vcr: { cassette_name: 'create_data_source' } do
      response = client.create_data_source(
        parent: { database_id: database_id },
        title: title,
        properties: properties
      )
      expect(response.title.first.plain_text).to eql 'Orbit 💜 Notion'
    end

    it 'updates', vcr: { cassette_name: 'update_data_source' } do
      response = client.update_data_source(
        data_source_id: data_source_id,
        title: title
      )
      expect(response.title.first.plain_text).to eql 'Orbit 💜 Notion'
    end

    it 'retrieves', vcr: { cassette_name: 'data_source' } do
      response = client.data_source(data_source_id: data_source_id)
      expect(response.title.first.plain_text).to eql 'Orbit 💜 Notion'
    end
  end
end
