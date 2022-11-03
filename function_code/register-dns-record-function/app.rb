# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

# 対象インスタンスの詳細を取得する
def get_instance_detail(instance_id)
  client = Aws::EC2::Client.new
  res = client.describe_instances({ instance_ids: [instance_id] })
  instance = res.reservations[0].instances[0]

  {
    "public_ip_address": instance[:public_ip_address],
    "tags": instance[:tags]
  }
end

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)

  event_json = JSON.generate(event)
  logger.info("event: #{event_json}")

  # eventから対象インスタンスID取得
  instance_id = event['detail']['instance-id']
  instance_detail = get_instance_detail(instance_id)
  logger.info("target instance detail: #{instance_detail}")

  # Recordがない場合は終了
  record_tags = instance_detail[:tags].filter { |item| item[:key] == 'Record' }
  if record_tags.length <= 0
    logger.info('Record tag not found. do nothing.')
    return { statusCode: 200, body: 'do noting.' }
  end

  state = event['detail']['state']
  case state
  when 'stopping'
    # レコード削除
    logger.info('delete DNS record.')
  when 'running'
    # レコード登録
    logger.info('register DNS record.')
  else
    logger.info("invalid record: #{state}")
    return { statusCode: 200, body: 'do noting.' }
  end

  { statusCode: 200, body: 'ok' }
end
