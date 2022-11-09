# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

require_relative 'lib/request_parser'

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)

  logger.info("lambda https endpoint event: #{JSON.generate(event)}")

  # pathとquery string取得
  request = RequestParser.new(event)
  logger.info("path: #{request.path}")
  logger.info("query: #{JSON.generate(request.query_string)}")

  # 有効なリクエストか確認する
  unless request.valid_path?
    logger.info("invalid path. (#{request.path}) do nothing.")
    return { statusCode: 400, body: "invalid path. (#{request.path})" }
  end

  unless request.query_string.key?('t')
    logger.info('invalid query string. do nothing.')
    return { statusCode: 400, body: 'invalid query string.' }
  end

  { statusCode: 200, body: 'ok' }
end
