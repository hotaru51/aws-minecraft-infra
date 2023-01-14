# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

require_relative 'lib/dns_record_manger'

# 対象インスタンスの詳細を取得する
def get_instance_detail(instance_id)
  logger = Logger.new(STDOUT)

  client = Aws::EC2::Client.new
  logger.info("get instance detail: instance_id = #{instance_id}")
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
  logger.info("target instance detail: #{JSON.generate(instance_detail)}")

  # Recordがない場合は終了
  record_tags = instance_detail[:tags].filter { |item| item[:key] == 'Record' }
  if record_tags.length <= 0
    logger.info('Record tag not found. do nothing.')
    return { statusCode: 200, body: 'do noting.' }
  end

  record_tag_value = record_tags[0][:value]
  public_ip_address = instance_detail[:public_ip_address]
  state = event['detail']['state']
  dns_record_manger = DnsRecordManager.new
  case state
  when 'stopping', 'shutting-down'
    # レコード削除
    dns_record_manger.delete_dns_record(record_tag_value)
  when 'running'
    # レコード登録
    dns_record_manger.register_dns_record(record_tag_value, public_ip_address)
  else
    logger.info("invalid state: #{state}")
    return { statusCode: 200, body: 'do noting.' }
  end

  { statusCode: 200, body: 'ok' }
end
