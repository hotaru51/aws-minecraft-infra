# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

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

# レコードの存在確認
def exists_dns_record?(record_name)
  logger = Logger.new(STDOUT)

  client = Aws::Route53::Client.new
  zone_id = ENV['PUBLIC_HOSTED_ZONE_ID']
  zone_name = ENV['PUBLIC_HOSTED_ZONE_NAME']
  target_record_name = "#{record_name}.#{zone_name}."

  # ホストゾーンのレコード一覧取得
  logger.info("get record list: zone_id = #{zone_id}")
  records = client.list_resource_record_sets({ hosted_zone_id: zone_id })

  filtered = records['resource_record_sets'].filter do |item|
    item['name'] == target_record_name && item['type'] == 'A'
  end
  logger.info("filtered record length: #{filtered.length}")

  filtered.length >= 1
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
  state = event['detail']['state']
  case state
  when 'stopping'
    # レコード削除
    logger.info('delete DNS record.')

    p exists_dns_record?(record_tag_value)
  when 'running'
    # レコード登録
    logger.info('register DNS record.')
  else
    logger.info("invalid record: #{state}")
    return { statusCode: 200, body: 'do noting.' }
  end

  { statusCode: 200, body: 'ok' }
end
