# frozen_string_literal: true

require 'json'

def lambda_handler(event:, context:)
  event_json = JSON.generate(event)

  { statusCode: 200, body: event_json }
end
