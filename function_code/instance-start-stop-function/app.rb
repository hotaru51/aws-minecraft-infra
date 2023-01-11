# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

require_relative 'lib/request_parser'
require_relative 'lib/token_authenticator'

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
    return { statusCode: 404, body: 'not found.' }
  end

  unless request.query_string.key?('t')
    logger.info('invalid query string. do nothing.')
    return { statusCode: 400, body: 'invalid request.' }
  end

  # トークンを照合する
  token = request.query_string['t']
  authenticator = TokenAuthenticator.new
  unless authenticator.authentication(token)
    logger.info("invalid token. (#{token}) do nothing.")
    return { statusCode: 400, body: 'invalid token.' }
  end

  target_instance = ENV['TARGET_INSTANCE']
  ec2_instance = Aws::EC2::Instance.new({ id: target_instance })
  ret_body = {}
  case request.path
  when '/start'
    # インスタンス起動
    logger.info("start instance. (#{target_instance})")
    res = ec2_instance.start.starting_instances[0]
    ret_body[:message] = 'ok(開始)'
    ret_body[:state] = res[:current_state][:name]
    ret_body[:instance_id] = res[:instance_id]
  when '/stop'
    logger.info("stop instance. (#{target_instance})")
    # インスタンス停止
    res = ec2_instance.stop.stopping_instances[0]
    ret_body[:message] = 'ok(停止)'
    ret_body[:state] = res[:current_state][:name]
    ret_body[:instance_id] = res[:instance_id]
  end

  { statusCode: 200, body: ret_body }
end
