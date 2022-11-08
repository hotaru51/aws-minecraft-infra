# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)

  logger.info("event: #{JSON.generate(event)}")
  { statusCode: 200, body: 'ok' }
end
