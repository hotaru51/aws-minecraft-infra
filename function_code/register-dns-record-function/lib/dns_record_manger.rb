# frozen_string_literal: true

require 'logger'
require 'json'
require 'aws-sdk'

class DnsRecordManager
  def initialize
    @client = Aws::Route53::Client.new
    @logger = Logger.new(STDOUT)
    @zone_id = ENV['PUBLIC_HOSTED_ZONE_ID']
    @zone_name = ENV['PUBLIC_HOSTED_ZONE_NAME']
  end

  # 対象のDNSレコードを取得する
  def get_target_dns_record(record_name)
    # ホストゾーンのレコード一覧取得
    @logger.info("get record list: zone_id = #{@zone_id}")
    records = @client.list_resource_record_sets({ hosted_zone_id: @zone_id })

    # 対象のレコードのオブジェクトを取得
    target_record_name = "#{record_name}.#{@zone_name}."
    records['resource_record_sets'].filter do |item|
      item['name'] == target_record_name && item['type'] == 'A'
    end
  end

  # 対象レコードの削除
  def delete_dns_record(record_name)
    # 対象レコードを取得
    target_records = get_target_dns_record(record_name)

    # 対象レコードが存在しない場合はreturn
    return if target_records.length <= 0

    # change_batch[:changes]に渡すオブジェクトの作成
    changes_arr = target_records.map do |item|
      { action: 'DELETE', resource_record_set: item }
    end

    # レコードの削除
    @logger.info('delete DNS record.')
    @client.change_resource_record_sets(
      {
        change_batch: {
          changes: changes_arr
        },
        hosted_zone_id: @zone_id
      }
    )
  end

  # レコードの追加
  def register_dns_record(record_name, public_ip_address)
    # change_batch[:changes]に渡すオブジェクトの作成
    changes_arr = [
      {
        action: 'UPSERT',
        resource_record_set: {
          name: "#{record_name}.#{@zone_name}",
          resource_records: [
            { value: public_ip_address }
          ],
          ttl: 60,
          type: 'A'
        }
      }
    ]

    # レコード作成
    @logger.info("create dns record: record: #{JSON.generate(changes_arr)}")
    @client.change_resource_record_sets(
      {
        change_batch: {
          changes: changes_arr
        },
        hosted_zone_id: @zone_id
      }
    )
  end
end
